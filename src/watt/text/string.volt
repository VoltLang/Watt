// Copyright © 2014-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
//! String utilities.
module watt.text.string;

import core.exception;
import watt.text.ascii: isWhite;
import watt.text.utf;
import watt.text.format : format;
import watt.text.sink : StringSink;


//! Helper alias for string args that are scoped.
alias StrArg = scope const(char)[];
//! Helper alias for string array args that are scoped.
alias StrArrayArg = scope const(char)[][];

/*!
 * Split string s by a given delimiter.  
 * ### Examples
 *     split("a=b", '=') ["a", "b"]
 *     split("a = b", '=') ["a ", " b"]
 *     split("a=b", '@') []
 */
fn split(s: string, delimiter: dchar) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: string[];
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		if (decode(s, ref i) == delimiter) {
			strings ~= s[base .. oldi];
			base = i;
		}
	}
	strings ~= s[base .. $];
	return strings;
}

/*!
 * Split `s` with a string delimiter.
 */
fn split(s: string, delimiter: StrArg) string[]
{
	strings: string[];
	do {
		i := s.indexOf(delimiter);
		if (i < 0) {
			break;
		}
		strings ~= s[0 .. cast(size_t)i];
		nexti := cast(size_t)i+delimiter.length;
		if (nexti > s.length) {
			break;
		}
		if (nexti == s.length) {
			strings ~= "";
		}
		s = s[nexti .. $];
	} while (s.length > 0);
	if (s.length > 0) {
		if (s == delimiter) {
			strings ~= "";
		} else {
			strings ~= s;
		}
	}
	return strings;
}

/*!
 * Split `s` by \n, \r, and \r\n.
 */
fn splitLines(s: string) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: string[];
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		c := decode(s, ref i);
		if (c == '\n' || c == '\r') {
			strings ~= s[base .. oldi];
			base = i;
			if (c == '\r' && base < s.length && s[base] == '\n') {
				base++;
				i++;
			}
		}
	}
	strings ~= s[base .. $];
	return strings;
}

/*!
 * Remove whitespace before and after `str`, as defined by `watt.ascii.isWhite`.
 * ### Examples
 *     strip("  apple  ") -> "apple"
 *     strip("  apple  pie  ") -> "apple pie"
 */
fn strip(str: StrArg) string
{
	start: size_t;
	stop := str.length;
	for(; start < str.length; start++) {
		if (!isWhite(str[start])) {
			break;
		}
	}
	for(; start < stop; stop--) {
		if (!isWhite(str[stop-1])) {
			break;
		}
	}
	return start == stop ? null : str[start .. stop];
}

/*!
 * Remove leading whitespace from `str`, as defined by `watt.ascii.isWhite`.
 */
fn stripLeft(str: string) string
{
	foreach (i, char c; str) {
		if (!isWhite(c)) {
			return str[i .. $];
		}
	}
	return null;
}

/*!
 * Remove trailing whitespace, as defined by `watt.ascii.isWhite`.
 */
fn stripRight(str: string) string
{
	foreach_reverse (i, char c; str) {
		if (!isWhite(c)) {
			return str[0 .. i+1];
		}
	}
	return null;
}

//! Return how many times `c` occurs in `s`.
fn count(str: StrArg, c: dchar) size_t
{
	n, i: size_t;
	while (i < str.length) {
		if (decode(str, ref i) == c) {
			n++;
		}
	}
	return n;
}

/*!
 * Returns the index of the first place `c` occurs in `str`,
 * or `-1` if it doesn't at all.
 */
fn indexOf(str: StrArg, c: dchar) ptrdiff_t
{
	i, oldi: size_t;
	while (i < str.length) {
		oldi = i;
		if (decode(str, ref i) == c) {
			if (oldi >= ptrdiff_t.max) {
				throw new Exception("indexOf: string too big.");
			}
			return cast(ptrdiff_t) oldi;
		}
	}
	return -1;
}

/*!
 * Returns the index of the last place `c` occurs in `str`, -1 otherwise.
 */
fn lastIndexOf(str: StrArg, c: dchar) ptrdiff_t
{
	foreach_reverse (i, dchar e; str) {
		if (e == c) {
			return cast(ptrdiff_t)i;
		}
	}
	return -1;
}

/*!
 * If the substring `sub` occurs in `s`, return the index where it occurs.
 * Otherwise, return `-1`.
 */
fn indexOf(str: StrArg, sub: StrArg) ptrdiff_t
{
	if (sub.length == 0) {
		return -1;
	}
	i: size_t;
	while (i < str.length) {
		remaining := str.length - i;
		if (remaining < sub.length) {
			return -1;
		}
		if (str[i .. i + sub.length] == sub) {
			if (i >= ptrdiff_t.max) {
				throw new Exception("indexOf: string to big.");
			}
			return cast(ptrdiff_t) i;
		}
		decode(str, ref i);
	}
	return -1;
}

/*!
 * Return the index in which `s` first occurs in `ss`, or `-1`.
 */
fn indexOf(ss: StrArrayArg, str: StrArg) ptrdiff_t
{
	foreach (i, e; ss) {
		if (e == str) {
			return cast(ptrdiff_t)i;
		}
	}
	return -1;
}

/*!
 * Returns a copy of `s` with occurences of `from` replaced with `to`, or `s` on its own
 * if `from` does not occur.
 */
fn replace(str: StrArg, from: StrArg, to: StrArg) string
{
	sink: StringSink;
	result: string;
	i: ptrdiff_t;
	do {
		i = indexOf(str, from);
		if (i == -1) {
			sink.sink(str);
		} else {
			si := cast(size_t)i;
			sink.sink(str[0 .. si]);
			sink.sink(to);
			str = str[si + from.length .. $];
		}
	} while (i != -1 && str.length > 0);

	return sink.toString();
}

//! Returns a non-zero value if @p str starts with one of the strings given by @p beginnings.
fn startsWith(str: StrArg, beginnings: StrArrayArg...) int
{
	result: int;
	foreach (beginning; beginnings) {
		if (beginning.length > str.length) {
			continue;
		}
		if (str[0 .. beginning.length] == beginning) {
			result++;
		}
	}
	return result;
}

//! Returns non-zero if @p str ends with one of the strings given by @p ends.
fn endsWith(str: StrArg, ends: StrArrayArg...) int
{
	result: int;
	foreach (end; ends) {
		if (end.length > str.length) {
			continue;
		}
		if (str[$ - end.length .. $] == end) {
			result++;
		}
	}
	return result;
}

//! Join an array of strings into one string, separated by `sep`.
fn join(ss: StrArrayArg, sep: StrArg = "") string
{
	outs: StringSink;
	foreach (i, e; ss) {
		outs.sink(e);
		if (i < ss.length - 1) {
			outs.sink(sep);
		}
	}
	return outs.toString();
}
