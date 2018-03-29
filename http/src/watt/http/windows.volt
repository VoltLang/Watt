// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
//! Windows implementation of Http requests.
module watt.http.windows;

import watt.algorithm : min;
import watt.http : HttpInterface, RequestInterface;
import watt.text.string : strip;

version(Windows):

import core.c.windows;


//! Win32 implementation of `HttpInterface`.
class Http : HttpInterface
{
private:
	hSession: HINTERNET;
	mNew: Request[];
	mReqs: Request[];

public:
	this()
	{
		name: immutable(wchar)[] = convert8To16("ShipHttp");

		hSession = WinHttpOpen(name.ptr,
			WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
			WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS,
			WINHTTP_FLAG_ASYNC);

		// Some install of windows won't connect if SSL is in the protocols list at *all*. @todo
		protocol :=  WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2;
		WinHttpSetOption(hSession, WINHTTP_OPTION_SECURE_PROTOCOLS, cast(void*)&protocol,
			cast(DWORD)typeid(protocol).size);
	}

	override fn isEmpty() bool
	{
		return mNew.length == 0 && mReqs.length == 0;
	}

	override fn perform()
	{
		foreach(req; mNew) {
			req.fire();
			mReqs ~= req;
		}
		mNew = null;

		count: size_t;
		foreach(i, req; mReqs) {
			if (!req.mDone) {
				mReqs[count++] = req;
			}
		}

		mReqs = mReqs[0 .. count];
	}

	override fn loop(cb: dg() = null)
	{
		while (!isEmpty()) {
			perform();
			cb();
			Sleep(1000);  // Stupid, but it does okay.
		}
	}
}

//! Win32 implementation of `RequestInterface`.
class Request : RequestInterface
{
private:
	mHttp: Http;
	mCon, mReq: HINTERNET;

	mError: bool;
	mErrorString: char[255];
	mErrorLength: size_t;
	mManualError: string;
	mDone: bool;

	mHeader: char*;
	mHeaderSize: size_t;

	mData: void*;
	mDataSize: size_t;
	mContentLength: DWORD;

	mDebug: char*;
	mDebugSize: size_t;

	mReadMutex: HANDLE;

public:
	this(http: Http)
	{
		assert(http !is null);
		this.mHttp = http;
		http.mNew ~= this;
		mReadMutex = CreateMutexA(null, FALSE, null);
		super(http);
	}

	~this()
	{
		cleanup();
		if (mHeader !is null) {
			free(cast(void*)mHeader);
		}
		if (mData !is null) {
			free(mData);
		}
		if (mDebug !is null) {
			free(cast(void*)mDebug);
		}
		CloseHandle(mReadMutex);
	}

	override fn getData() void[]
	{
		return mData[0 .. mDataSize];
	}

	override fn getString() string
	{
		return new string((cast(char*)mData)[0 .. mDataSize]);
	}

	override fn completed() bool
	{
		return mDone;
	}

	override fn errorGenerated() bool
	{
		return mError;
	}

	override fn errorString() string
	{
		if (mManualError !is null) {
			return mManualError;
		}
		/* FormatMessage seems to end each message with \r\n, but I'm not sure if it's EVERY message,
		 * so just play it safe and strip() it.
		 */
		return strip(cast(string)mErrorString[0 .. mErrorLength]);
	}

	override fn bytesDownloaded() size_t
	{
		return mDataSize;
	}

	override fn contentLength() size_t
	{
		return cast(size_t)mContentLength;
	}

private:
	fn fire()
	{
		actionPtr: immutable(wchar)* = null; // Get can be null
		serverPtr: immutable(wchar)* = convert8To16(this.server).ptr;
		urlPtr: immutable(wchar)* = convert8To16(this.url).ptr;
		bResults: BOOL;

		mCon = WinHttpConnect(
			mHttp.hSession, serverPtr, port, 0);
		if (mCon is null) {
			return raiseError();
		}

		mReq = WinHttpOpenRequest(
			mCon, actionPtr, urlPtr, null,
			WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES,
			secure ? WINHTTP_FLAG_SECURE : 0);
		if (mReq is null) {
			return raiseError();
		}

		WinHttpSetStatusCallback(mReq, callbackFunction,
			WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS, 0);

		bResults = WinHttpSendRequest(
			mReq, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
			WINHTTP_NO_REQUEST_DATA, 0, 0, cast(DWORD_PTR)cast(void*)this);
		if (!bResults) {
			return raiseError();
		}
	}

	fn receive()
	{
		// Tell WinHttp to start reading headers and data.
		if (!WinHttpReceiveResponse(mReq, null)) {
			raiseError();
		}
	}

	fn queryData()
	{
		if (!WinHttpQueryDataAvailable(mReq, null)) {
			raiseError();
		}
	}

	fn redirected()
	{

	}

	fn readHeaders()
	{
		size: DWORD;
		if (!WinHttpQueryHeaders(
			mReq, WINHTTP_QUERY_RAW_HEADERS_CRLF,
			WINHTTP_HEADER_NAME_BY_INDEX, null, &size,
			WINHTTP_NO_HEADER_INDEX)) {

			err: DWORD = GetLastError();
			if (err != 122/*ERROR_INSUFFICIENT_BUFFER*/) {
				return raiseError();
			}
		}

		if (size == 0) {
			return;
		}

		mHeader = cast(char*)realloc(cast(void*)mHeader, size);
		if (!WinHttpQueryHeaders(
			mReq, WINHTTP_QUERY_RAW_HEADERS_CRLF,
			WINHTTP_HEADER_NAME_BY_INDEX, cast(void*)mHeader,
			&size, WINHTTP_NO_HEADER_INDEX)) {
			free(cast(void*)mHeader);
			return raiseError();
		}

		dwSize: DWORD = cast(DWORD)typeid(DWORD).size;
		WinHttpQueryHeaders(mReq, 
                     WINHTTP_QUERY_CONTENT_LENGTH | WINHTTP_QUERY_FLAG_NUMBER,
                     WINHTTP_HEADER_NAME_BY_INDEX, 
                     cast(void*)&mContentLength, 
                     &dwSize, 
                     WINHTTP_NO_HEADER_INDEX);

		// Move onto reading data.
		queryData();
	}

	fn readData(size: size_t)
	{
		mData = realloc(mData, mDataSize + size);
		if (!WinHttpReadData(mReq, mData + mDataSize,
		    cast(DWORD)size, null)) {
			raiseError();
		}
	}

	fn cleanup()
	{
		if (mReq !is null) {
			WinHttpSetStatusCallback(mReq,
				cast(WINHTTP_STATUS_CALLBACK)null, 0, 0);
			WinHttpCloseHandle(mReq);
			mReq = null;
		}

		if (mCon !is null) {
			WinHttpCloseHandle(mCon);
			mCon = null;
		}
	}

	fn raiseCompleted()
	{
		cleanup();
		mDone = true;
	}

	fn raiseError()
	{
		win32ErrorString(mErrorString.ptr, mErrorString.length, out mErrorLength);
		cleanup();
		mError = true;
		mDone = true;
	}

	fn debugStr(str: string)
	{
		newSize := str.length + mDebugSize + 1;

		mDebug = cast(char*)realloc(cast(void*)mDebug, newSize);
		mDebug[mDebugSize .. mDebugSize + str.length] = str;
		mDebug[newSize-1] = '\n';
		mDebugSize = newSize;
	}
}

private:

/* This is copying into a pointer to a static array not because
 * the author is insane (well not *only* because the author is insane)
 * but because this gets called by callbackFunction, and we cannot
 * use the GC.
 */
fn win32ErrorString(buf: char*, bufLen: size_t, out strLength: size_t)
{
	code := GetLastError();
	msg: char*;
	count := FormatMessageA(cast(DWORD)(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_IGNORE_INSERTS),
	cast(void*)GetModuleHandleA("winhttp.dll"), code, 0, cast(LPCSTR)&msg, 0, null);
	strLength = min(count, bufLen);
	buf[0 .. strLength] = msg[0 .. strLength];
	LocalFree(cast(HLOCAL)msg);
}

import core.c.stdlib : realloc, free;

/* Anything called from the callbackFunction cannot use the GC,
 * as we are in ASYNC mode and it will not be called from the
 * main thread.
 */

extern(Windows) fn callbackFunction(
	hInternet: HINTERNET,
	dwContext: DWORD_PTR,
	dwInternetStatus: DWORD,
	lpvStatusInformation: LPVOID,
	dwStatusInformationLength: DWORD)
{
	if (dwContext == 0) {
		return;
	}

	req := cast(Request)dwContext;
	WaitForSingleObject(req.mReadMutex, INFINITE);
	scope (exit) ReleaseMutex(req.mReadMutex);
	switch (dwInternetStatus) {
	case WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE:
		req.receive();
		break;
	case WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE:
		req.readHeaders();
		break;
	case WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE:
		req.readData(*cast(LPDWORD)lpvStatusInformation);
		break;
	case WINHTTP_CALLBACK_STATUS_READ_COMPLETE:
		req.mDataSize += dwStatusInformationLength;
		if (dwStatusInformationLength == 0) {
			req.raiseCompleted();
		} else {

			req.queryData();
		}
		break;
	case WINHTTP_CALLBACK_STATUS_REDIRECT:
		req.redirected();
		break;
	case WINHTTP_CALLBACK_STATUS_REQUEST_ERROR:
		req.raiseError();
		break;
	case WINHTTP_CALLBACK_STATUS_SECURE_FAILURE:
		val := *cast(DWORD*)lpvStatusInformation;
		switch (val) {
		case WINHTTP_CALLBACK_STATUS_FLAG_CERT_REV_FAILED:
			req.mManualError= "Certification revocation checking has been enabled, but the revocation check failed to verify whether a certificate has been revoked. The server used to check for revocation might be unreachable. (WINHTTP_CALLBACK_STATUS_FLAG_CERT_REV_FAILED)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CERT:
			req.mManualError = "SSL certificate is invalid. (WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CERT)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_CERT_REVOKED:
			req.mManualError = "SSL certificate was revoked. (WINHTTP_CALLBACK_STATUS_FLAG_CERT_REVOKED)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CA:
			req.mManualError = "The function is unfamiliar with the Certificate Authority that generated the server's certificate. (WINHTTP_CALLBACK_STATUS_FLAG_INVALID_CA)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_CERT_CN_INVALID:
			req.mManualError = "SSL certificate common name (host name field) is incorrect, for example, if you entered www.microsoft.com and the common name on the certificate says www.msn.com. (WINHTTP_CALLBACK_STATUS_FLAG_CERT_CN_INVALID)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_CERT_DATE_INVALID:
			req.mManualError = "SSL certificate date that was received from the server is bad. The certificate is expired. (WINHTTP_CALLBACK_STATUS_FLAG_CERT_DATE_INVALID)";
			break;
		case WINHTTP_CALLBACK_STATUS_FLAG_SECURITY_CHANNEL_ERROR:
			req.mManualError = "The application experienced an internal error loading the SSL libraries. (WINHTTP_CALLBACK_STATUS_FLAG_SECURITY_CHANNEL_ERROR)";
			break;
		default:
			break;
		}
		break;
	default:
	}
}

enum u32 CP_UTF8 = 65001;
extern(Windows) fn MultiByteToWideChar(
	CodePage: u32, dwFlags: DWORD, lpMultiByteStr: LPCSTR, cbMultiByte: i32,
	lpWideCharStr: LPWSTR, cchWideChar: i32) i32;

fn convert8To16(str: const(char)[]) immutable(wchar)[]
{
	numChars: i32 = MultiByteToWideChar(CP_UTF8, 0, str.ptr, -1, null, 0);
	w := new wchar[](numChars+1);

	numChars = MultiByteToWideChar(CP_UTF8, 0, str.ptr, -1, w.ptr, numChars);
	w[numChars] = 0;
	w = w[0 .. numChars];
	return cast(immutable(wchar)[])w;
}
