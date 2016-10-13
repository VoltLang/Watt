// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.path;

import core.exception;
import watt.text.sink;
import watt.text.format;
import watt.text.string;
import watt.path;

fn normalizePath(path: SinkArg) string
{
	buf := new char[](path.length);
	bufIndex: size_t = 0;

	slash := '/';
	absolute := path[0].isSlash();
	version (Windows) {
		slash = '\\';
		colonIndex := path.indexOf(':');
		drive: string;
		if (colonIndex > 0) {
			drive = path[0 .. colonIndex+1];
			absolute = true;
		}
	}

	fn isSlash(c: dchar) bool {
		version (Windows) {
			return c == '/' || c == '\\';
		} else {
			return c == '/';
		}
	}

	nonDot: bool;
	for (i: size_t; i < path.length;) {
		if (path[i].isSlash() && i < path.length-1 && path[i+1].isSlash()) {
			// "Replace multiple Separator elements with a single one."
			i++;
		} else if (path[i].isSlash() && i < path.length-1 && path[i+1] == '.' &&
			(i > path.length-2 || path[i+2] != '.')) {
			// "Eliminate each . path name element."
			i += 2;
		} else if (path[i].isSlash() &&
		path[i+1] == '.' &&
		path[i+2] == '.' &&
		(i+3 == path.length || path[i+3].isSlash()) && nonDot) {
			slashIndex := buf[0 .. bufIndex].lastIndexOf(slash);
			version (Windows) {
				if (slashIndex < 0) {
					slashIndex = buf[0 .. bufIndex].lastIndexOf('/');
				}
			}
			if (slashIndex < 0) {
				slashIndex = 0;
			}
			bufIndex = cast(size_t)slashIndex;
			i += 3;
			if (absolute && bufIndex == 0) {
				buf[bufIndex++] = slash;
			} else if (bufIndex == 0) {
				nonDot = false;
				if (path[i].isSlash()) {
					i++;  // Skip slash.
				}
			}
			if (cast(string)buf[0 .. bufIndex] == "..") {
				nonDot = false;
			}
		} else {
			if (!path[i].isSlash() && path[i] != '.') {
				nonDot = true;
			}
			c: char = path[i++];
			version (Windows) {
				// Normalise.
				if (c == '/') {
					c = '\\';
				}
			}
			buf[bufIndex++] = c;
		}
	}

	str := cast(string)buf[0 .. bufIndex];
	// "The returned path ends in a slash only if it represents a root directory."
	if (str.length > 1 && str[$-1].isSlash()) {
		str = str[0 .. $-1];
	}

	if (str.length == 0) {
		// "If the result of this process is an empty string...return the string "."."
		return ".";
	} else {
		version (Windows) {
			if (drive.length > 0) {
				return drive ~ str;
			} else {
				return str;
			}
		}
		return str;
	}
}
