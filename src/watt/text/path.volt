// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.path;

import core.exception;
import watt.text.sink;
import watt.text.format;
import watt.path;


fn normalizePathWindows(n: SinkArg) string
{
	pos: size_t;
	r: char[4096];

	if (r.length < n.length) {
		throw new Exception(format("path too long '%s'", n));
	}

	foreach (i, char c; n) {
		version (Windows) if (c == '/') {
			c = '\\';
		}

		// TODO much better logic here for normalizing paths.
		r[pos++] = c;
	}

	return new string(r[0 .. pos]);
}

fn normalizePathPosix(n: SinkArg) string
{
	// TODO much better logic here for normalizing paths.
	return new string(n);
}

version (Windows) {
	alias normalizePath = normalizePathWindows;
} else version (Posix) {
	alias normalizePath = normalizePathPosix;
}
