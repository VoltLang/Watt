// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
//! Contains implementations for HTTP requests.
module watt.http;

/*!
 * An object that handles multiple HTTP requests.
 */
interface HttpInterface
{
public:
	//! Does this interface have any requests pending?
	fn isEmpty() bool;

	//! Launch any new requests, and mark requests that are complete.
	fn perform();
}

//! An object that models an HTTP request.
abstract class RequestInterface
{
public:
	//! The address of the server to connect to.
	server: string;
	//! The url to connect to on the server.
	url: string;
	//! The port to connect by.
	port: u16;
	//! Should this request use HTTPS?
	secure: bool;

public:
	//! Construct a new request using the given http interface.
	this(http: HttpInterface)
	{
	}

	//! Get the result of the request.
	abstract fn getString() string;
}

version (Windows) {
	public import watt.http.windows;
} else {
	public import watt.http.curl;
}
