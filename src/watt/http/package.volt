// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
//! Contains implementations for HTTP requests.
module watt.http;

interface HttpInterface
{
public:
	fn isEmpty() bool;

	fn perform();
}

abstract class RequestInterface
{
public:
	server: string;
	url: string;
	port: u16;
	secure: bool;

public:
	this(http: Http)
	{
	}

	abstract fn getString() string;
}

version (Windows) {
	public import watt.http.windows;
} else {
	public import watt.http.curl;
}
