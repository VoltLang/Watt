// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Functions for dealing with path strings.
module watt.text.path;

import core.exception;
import watt.text.sink;
import watt.text.format;
import watt.text.string;
import watt.path;

/*!
 * Given a path, return a representation of that path that is universal.
 *
 * That is to say, given two paths to the same location (from the same starting point),
 * normalizePath(A) == normalizePath(B).
 */
fn normalizePath(path: SinkArg) string
{
	version (Windows) {
		return normalizePathImpl(path, true);
	} else {
		return normalizePathImpl(path, false);
	}
}

/*!
 * Given two paths, return a path composed of both.
 *
 * If the first path doesn't end in a path separator, one
 * will be added. Only one path separator will separate
 * `base` and `tail`.
 *
 * ### Examples
 * ```volt
 * // On Windows, backslash will separate.
 * concatenatePath("a", "b");  "a/b"
 * concatenatePath("a/", "b"); "a/b"
 * concatenatePath("a/", "/b"); "a/b"
 * ```
 */
fn concatenatePath(base: string, tail: string) string
{
	outbuf: StringSink;
	outbuf.sink(base);
	if (!base[$-1].isSlash()) {
		outbuf.sink(dirSeparator);
	}
	if (tail.length > 0 && tail[0].isSlash()) {
		tail = tail[1 .. $];
	}
	outbuf.sink(tail);
	return outbuf.toString();
}

/*!
 * Given a path, return a path that could be a subpath.
 *
 * A full path under windows contains a drive letter and a colon before '\'.
 * If we want to make a subdirectory based on a full path, get rid of the colon,
 * as it cannot exist in a valid windows filename.
 */
fn makePathAppendable(s: string) string
{
	version (Windows) {
		return s.replace(":", "");
	} else {
		return s;
	}
}

//! Normalize a path using POSIX rules, regardless of the current platform.
fn normalizePathPosix(path: SinkArg) string
{
	return normalizePathImpl(path, false);
}

//! Normalize a path using Windows rules, regardless of the current platform.
fn normalizePathWindows(path: SinkArg) string
{
	return normalizePathImpl(path, true);
}

private fn normalizePathImpl(path: SinkArg, windowsPaths: bool) string
{
	buf := new char[](path.length);
	bufIndex: size_t = 0;

	slash := '/';
	absolute := path[0].isSlash();
	colonIndex: ptrdiff_t = -1;
	drive: string;
	if (windowsPaths) {
		slash = '\\';
		colonIndex = path.indexOf(':');
		if (colonIndex > 0) {
			drive = path[0 .. colonIndex+1];
			absolute = true;
		}
	}

	fn isSlash(c: dchar) bool {
		if (windowsPaths) {
			return c == '/' || c == '\\';
		} else {
			return c == '/';
		}
	}

	nonDot: bool;
	for (i: size_t = cast(size_t)colonIndex+1; i < path.length;) {
		if (path[i].isSlash() && i < path.length-1 && path[i+1].isSlash()) {
			// "Replace multiple Separator elements with a single one."
			i++;
		} else if (i == 0 && path[i] == '.' && path.length >= 2 && path[i+1].isSlash()) {
			// Eliminate ./ at the start.
			i += 2;
		} else if (path[i].isSlash() && i < path.length-1 && path[i+1] == '.' &&
			(i+1 == path.length-1 || path[i+2].isSlash())) {
			// "Eliminate each /./ path name element."
			i += 2;
		} else if (i+2 < path.length &&
			path[i].isSlash() &&
			path[i+1] == '.' &&
			path[i+2] == '.' &&
			(i+3 == path.length || path[i+3].isSlash()) && nonDot) {
			slashIndex := buf[0 .. bufIndex].lastIndexOf(slash);
			if (windowsPaths) {
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
			nonDot = !path[i].isSlash() && path[i] != '.';
			c: char = path[i++];
			if (windowsPaths) {
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
		if (windowsPaths) {
			if (drive.length > 0) {
				return new string(drive, str);
			} else {
				return str;
			}
		} else {
			return str;
		}
	}
}
