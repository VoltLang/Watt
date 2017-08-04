// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
/*!
 * Provides a simple interface for making HTTP requests.  
 * `HttpInterface` and `RequestInterface` are implemented with classes
 * with the names `Http` and `Request`, respectively. This is to allow
 * an different implementation for each platform.
 * ### Example
 * ```volt
 * import watt.http;
 * ...
 * http := new Http();
 * req  := new Request(http);
 * req.server = "www.example.com";
 * req.port = 80;
 * while (!http.isEmpty()) http.perform();
 * result := req.toString();
 * ```
 */
module watt.http;

/*!
 * Manage multiple HTTP requests.  
 * Every `Request` is create with a reference to an `Http` object,
 * which is in charge of launching the requests.
 */
interface HttpInterface
{
public:
	//! @returns `true` if this has any requests pending.
	fn isEmpty() bool;

	/*!
	 * Launch new requests, and mark requests that are complete.  
	 * Doesn't block if requests are still pending -- check `isEmpty`
	 * to see if all pending `Request`s are complete.
	 */
	fn perform();
}

//! An HTTP request.
abstract class RequestInterface
{
public:
	/*!
	 * The address of the server to connect to.  
	 * This doesn't include the protocol.  
	 * `"www.example.com"`, not `"http://www.example.com"`.
	 */
	server: string;
	/*!
	 * The url to connect to on the server.  
	 * So if `server` is `"www.example.com"`, and this is
	 * set to `"/index.html"`, then this request would look up
	 * `"www.example.com/index.html"`.
	 */
	url: string;
	//! The port to connect to the remote server with.
	port: u16;
	//! Should this request use HTTPS?
	secure: bool;

public:
	//! Construct a new `Request` that is managed by `http`.
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
