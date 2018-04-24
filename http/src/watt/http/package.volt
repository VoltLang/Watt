// Copyright 2016, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
/*!
 * A simple interface for making HTTP requests.
 *
 * `HttpInterface` and `RequestInterface` are implemented with classes
 * with the names `Http` and `Request`. Import `watt.http`, and it will
 * import the appropriate implementation for the current platform.
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

enum Status
{
	Continue,
	Abort
}

/*!
 * Manage multiple HTTP requests.
 *
 * Handles the launching and tracking of multiple `Requests`.
 */
interface HttpInterface
{
public:
	//! @returns `true` if this has any requests pending.
	fn isEmpty() bool;

	/*!
	 * Launch new requests, and mark requests that are complete.
	 *
	 * Doesn't block if requests are still pending -- check `isEmpty`
	 * to see if all pending `Request`s are complete.
	 */
	fn perform();

	/*!
	 * Complete all requests.
	 *
	 * Blocks until all requests are completed. Periodically calls
	 * `cb` if it is non-null.
	 */
	fn loop(cb: dg() Status = null);
}

//! An HTTP request.
abstract class RequestInterface
{
public:
	/*!
	 * The address of the server to connect to.
	 *
	 * This doesn't include the protocol.  
	 * `"www.example.com"`, not `"http://www.example.com"`.
	 */
	server: string;
	/*!
	 * The url to connect to on the server.
	 *
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
	abstract fn getData() void[];

	//! Get the result of the request as a string.
	abstract fn getString() string;

	//! Has this request completed?
	abstract fn completed() bool;

	//! Was an error generated for this request?
	abstract fn errorGenerated() bool;

	//! Get an error string.
	abstract fn errorString() string;

	//! How many bytes have been downloaded so far?
	abstract fn bytesDownloaded() size_t;

	//! How big is the content? If unknown, this is zero.
	abstract fn contentLength() size_t;
}

version (Windows) {
	public import watt.http.windows;
} else {
	public import watt.http.curl;
}
