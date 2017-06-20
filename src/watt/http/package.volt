// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
//! Contains implementations for HTTP requests.
module watt.http;

version (Windows) {
	public import watt.http.windows;
} else {
	public import watt.http.curl;
}
