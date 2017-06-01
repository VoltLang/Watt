// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
module watt.http.curl;

version (!Windows):

import core.c.stdlib : realloc, free;

import watt.io : output;

import watt.http.libcurl;


class Http
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

	fn isEmpty() bool
	{
		return mNew.length == 0 && mReqs.length == 0;
	}

	fn perform()
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

class Request
{
public:
	server: string;
	url: string;
	port: u16;
	secure: bool;

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
	}

	~this()
	{
		cleanup();
		if (mData !is null) {
			free(mData);
			mData = null;
		}
	}

	fn getString() string
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
