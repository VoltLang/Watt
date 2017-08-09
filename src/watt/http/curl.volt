// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
//! A libcurl implementation of HTTP requests.
module watt.http.curl;

version (!Windows):

import core.c.stdlib : realloc, free;

import watt.io : output;

import watt.http : HttpInterface, RequestInterface;


class Http : HttpInterface
{
private:
	mMulti: CURLM*;
	mNew: Request[];
	mReqs: Request[];

public:
	this()
	{
		mMulti = curl_multi_init();
	}

	~this()
	{
		foreach (req; mReqs) {
			req.cleanup();
		}

		if (mMulti !is null) {
			curl_multi_cleanup(mMulti);
			mMulti = null;
		}
	}

	override fn isEmpty() bool
	{
		return mNew.length == 0 && mReqs.length == 0;
	}

	override fn perform()
	{
		if (mMulti is null) {
			return;
		}

		foreach (req; mNew) {
			req.fire();
			mReqs ~= req;
		}
		mNew = null;

		num: i32;
		curl_multi_perform(mMulti, &num);

		if (num == cast(i32)mReqs.length) {
			return;
		}

		// We know that there is at least one message left.
		num = 1;

		// Get all messages from the multi.
		while (num > 0) {
			m := curl_multi_info_read(mMulti, &num);
			if (m is null ||
			    m.msg != CURLMSG.CURLMSG_DONE) {
				continue;
			}

			// Get and remove request from array.
			req: Request;
			foreach (i, loopReq; mReqs) {
				if (req !is null) {
					mReqs[i-1] = loopReq;
				}
				if (loopReq.mEasy is m.easy_handle) {
					req = loopReq;
					continue;
				}
			}
			mReqs = mReqs[0 .. $-1];

			curl_multi_remove_handle(mMulti, req.mEasy);
			req.raiseDone();
		}
	}
}

class Request : RequestInterface
{
private:
	mHttp: Http;
	mEasy: CURL*;
	mUrl: string;

	mDataSize: size_t;
	mData: void*;

	mError: bool;
	mDone: bool;

public:
	this(http: Http)
	{
		mHttp = http;
		http.mNew ~= this;
		super(http);
	}

	~this()
	{
		cleanup();
		if (mData !is null) {
			free(mData);
			mData = null;
		}
	}

	override fn getString() string
	{
		return new string((cast(char*)mData)[0 .. mDataSize]);
	}

private:
	fn fire()
	{
		mEasy = curl_easy_init();
		if (mEasy is null) {
			return raiseError();
		}

		mUrl = secure ? "https://" : "http://";
		mUrl ~= server;
		mUrl ~= "/" ~ url;
		mUrl ~= '\0';

		curl_easy_setopt(mEasy, CURLoption.URL, mUrl.ptr);
		curl_easy_setopt(mEasy, CURLoption.PORT, cast(long)port);
		curl_easy_setopt(mEasy, CURLoption.FOLLOWLOCATION, cast(long)1);

		curl_easy_setopt(mEasy, CURLoption.READFUNCTION, myRead);
		curl_easy_setopt(mEasy, CURLoption.READDATA, this);
		curl_easy_setopt(mEasy, CURLoption.WRITEFUNCTION, myWrite);
		curl_easy_setopt(mEasy, CURLoption.WRITEDATA, this);

		curl_multi_add_handle(mHttp.mMulti, mEasy);
	}

	/*!
	 * Data going from this process to the host.
	 */
	extern(C) global fn myRead(buffer: void*, size: size_t,
	                           nitems: size_t, instream: void*) size_t
	{
		//writefln("%s", buffer[0 .. size * nitems]);
		return size * nitems;
	}

	/*!
	 * Data comming from the host to this process.
	 */
	extern(C) global fn myWrite(buffer: void*, size: size_t,
	                        	nitems: size_t, outstream: void*) size_t
	{
		req := cast(Request)outstream;

		size *= nitems;
		newSize: size_t = req.mDataSize + size;
		req.mData = realloc(req.mData, req.mDataSize + size);
		req.mData[req.mDataSize .. newSize] = buffer[0 .. size];

		// Update the total size.
		req.mDataSize += size;
		return size;
	}

	fn raiseError()
	{
		cleanup();
		mError = true;
		mDone = true;
	}

	fn raiseDone()
	{
		mDone = true;
	}

	fn cleanup()
	{
		if (mEasy !is null) {
			curl_easy_cleanup(mEasy);
			mEasy = null;
		}
	}
}


/*
 *
 * Internal lib curl bindings, here to avoid showing up in the documentation.
 *
 */

private extern(C):


struct CURL {}
struct CURLM {}

enum CURLcode
{
	CURLE_OK = 0,
	CURLE_UNSUPPORTED_PROTOCOL,
	CURLE_FAILED_INIT,
	CURLE_URL_MALFORMAT,
	CURLE_NOT_BUILT_IN,
	CURLE_COULDNT_RESOLVE_PROXY,
	CURLE_COULDNT_RESOLVE_HOST,
	CURLE_COULDNT_CONNECT,
	CURLE_FTP_WEIRD_SERVER_REPLY,
	CURLE_REMOTE_ACCESS_DENIED,
	CURLE_FTP_ACCEPT_FAILED,
	CURLE_FTP_WEIRD_PASS_REPLY,
	CURLE_FTP_ACCEPT_TIMEOUT,
	CURLE_FTP_WEIRD_PASV_REPLY,
	CURLE_FTP_WEIRD_227_FORMAT,
	CURLE_FTP_CANT_GET_HOST,
	CURLE_HTTP2,
	CURLE_FTP_COULDNT_SET_TYPE,
	CURLE_PARTIAL_FILE,
	CURLE_FTP_COULDNT_RETR_FILE,
	CURLE_OBSOLETE20,
	CURLE_QUOTE_ERROR,
	CURLE_HTTP_RETURNED_ERROR,
	CURLE_WRITE_ERROR,
	CURLE_OBSOLETE24,
	CURLE_UPLOAD_FAILED,
	CURLE_READ_ERROR,
	CURLE_OUT_OF_MEMORY,
	CURLE_OPERATION_TIMEDOUT,
	CURLE_OBSOLETE29,
	CURLE_FTP_PORT_FAILED,
	CURLE_FTP_COULDNT_USE_REST,
	CURLE_OBSOLETE32,
	CURLE_RANGE_ERROR,
	CURLE_HTTP_POST_ERROR,
	CURLE_SSL_CONNECT_ERROR,
	CURLE_BAD_DOWNLOAD_RESUME,
	CURLE_FILE_COULDNT_READ_FILE,
	CURLE_LDAP_CANNOT_BIND,
	CURLE_LDAP_SEARCH_FAILED,
	CURLE_OBSOLETE40,
	CURLE_FUNCTION_NOT_FOUND,
	CURLE_ABORTED_BY_CALLBACK,
	CURLE_BAD_FUNCTION_ARGUMENT,
	CURLE_OBSOLETE44,
	CURLE_INTERFACE_FAILED,
	CURLE_OBSOLETE46,
	CURLE_TOO_MANY_REDIRECTS ,
	CURLE_UNKNOWN_OPTION,
	CURLE_TELNET_OPTION_SYNTAX ,
	CURLE_OBSOLETE50,
	CURLE_PEER_FAILED_VERIFICATION,
	CURLE_GOT_NOTHING,
	CURLE_SSL_ENGINE_NOTFOUND,
	CURLE_SSL_ENGINE_SETFAILED,
	CURLE_SEND_ERROR,
	CURLE_RECV_ERROR,
	CURLE_OBSOLETE57,
	CURLE_SSL_CERTPROBLEM,
	CURLE_SSL_CIPHER,
	CURLE_SSL_CACERT,
	CURLE_BAD_CONTENT_ENCODING,
	CURLE_LDAP_INVALID_URL,
	CURLE_FILESIZE_EXCEEDED,
	CURLE_USE_SSL_FAILED,
	CURLE_SEND_FAIL_REWIND,
	CURLE_SSL_ENGINE_INITFAILED,
	CURLE_LOGIN_DENIED,
	CURLE_TFTP_NOTFOUND,
	CURLE_TFTP_PERM,
	CURLE_REMOTE_DISK_FULL,
	CURLE_TFTP_ILLEGAL,
	CURLE_TFTP_UNKNOWNID,
	CURLE_REMOTE_FILE_EXISTS,
	CURLE_TFTP_NOSUCHUSER,
	CURLE_CONV_FAILED,
	CURLE_CONV_REQD,
	CURLE_SSL_CACERT_BADFILE,
	CURLE_REMOTE_FILE_NOT_FOUND,
	CURLE_SSH,
	CURLE_SSL_SHUTDOWN_FAILED,
	CURLE_AGAIN,
	CURLE_SSL_CRL_BADFILE,
	CURLE_SSL_ISSUER_ERROR,
	CURLE_FTP_PRET_FAILED,
	CURLE_RTSP_CSEQ_ERROR,
	CURLE_RTSP_SESSION_ERROR,
	CURLE_FTP_BAD_FILE_LIST,
	CURLE_CHUNK_FAILED,
	CURLE_NO_CONNECTION_AVAILABLE,
	CURLE_SSL_PINNEDPUBKEYNOTMATCH,
	CURLE_SSL_INVALIDCERTSTATUS,
	CURL_LAST /* never use! */
}

enum CURLOPTTYPE_LONG          = 0;
enum CURLOPTTYPE_OBJECTPOINT   = 10000;
enum CURLOPTTYPE_STRINGPOINT   = 10000;
enum CURLOPTTYPE_FUNCTIONPOINT = 20000;
enum CURLOPTTYPE_OFF_T         = 30000;

enum CURLoption
{
	WRITEDATA        = CURLOPTTYPE_OBJECTPOINT   + 1,
	URL              = CURLOPTTYPE_STRINGPOINT   + 2,
	PORT             = CURLOPTTYPE_LONG          + 3,
	READDATA         = CURLOPTTYPE_OBJECTPOINT   + 9,
	WRITEFUNCTION    = CURLOPTTYPE_FUNCTIONPOINT + 11,
	READFUNCTION     = CURLOPTTYPE_FUNCTIONPOINT + 12,
	COOKIE           = CURLOPTTYPE_STRINGPOINT   + 22,
	FOLLOWLOCATION   = CURLOPTTYPE_LONG          + 52,
}


enum size_t CURL_READFUNC_ABORT = 0x10000000;
enum size_t CURL_READFUNC_PAUSE = 0x10000001;
alias curl_read_callback = fn!C(buffer: char*,
                                size: size_t,
                                nitems: size_t,
                                instream: void*) size_t;

enum size_t CURL_WRITEFUNC_PAUSE = 0x10000001;
alias curl_write_callback = fn!C(buffer: char*,
                                 size: size_t,
                                 nitems: size_t,
                                 outstream: void*) size_t;

enum CURLMcode
{
	CURLM_CALL_MULTI_PERFORM = -1,
	CURLM_OK = 0,
	CURLM_BAD_EASY_HANDLE = 2,
	CURLM_OUT_OF_MEMORY = 3,
	CURLM_INTERNAL_ERROR = 4,
	CURLM_BAD_SOCKET = 5,
	CURLM_UNKNOWN_OPTION = 6,
	CURLM_ADDED_ALREADY = 7,
}

enum CURLMSG
{
	CURLMSG_FIRST,
	CURLMSG_DONE,
	CURLMSG_LAST,
}

struct CURLMsg
{
	msg: CURLMSG;       /* what this message means */
	easy_handle: CURL*; /* the handle it concerns */
	union Data {
		whatever: void*;    /* message-specific data */
		result: CURLcode;   /* return code for transfer */
	}
	data: Data;
}

fn curl_easy_init() CURL*;
fn curl_easy_setopt(curl: CURL*, option: CURLoption, ...) CURLcode;
fn curl_easy_perform(curl: CURL*) CURLcode;
fn curl_easy_cleanup(curl: CURL*);

fn curl_multi_init() CURLM*;
fn curl_multi_cleanup(multi_handle: CURLM*) CURLMcode;
fn curl_multi_perform(multi_handle: CURLM*, running_handles: i32*) CURLMcode;
fn curl_multi_add_handle(multi_handle: CURLM*, curl_handle: CURL*) CURLMcode;
fn curl_multi_remove_handle(multi_handle: CURLM*, curl_handle: CURL*) CURLMcode;
fn curl_multi_info_read(multi_handle: CURLM*, msgs_in_queue: i32*) CURLMsg*;
