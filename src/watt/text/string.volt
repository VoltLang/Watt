// Copyright 2014-2015, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Simple functions for working with `string` values.
 *
 * The functions that return a string, will return a copy --
 * the original will not be changed.
 *
 * ### Example
 * ```volt
 * a := " apple ";
 * b := strip(a);
 * assert(a == " apple ");
 * assert(b == "apple");
 * ```
 */
module watt.text.string;

import core.exception;
import watt.text.ascii: isWhite;
import watt.text.utf;
import watt.text.format : format;
import watt.text.sink : StringSink, StringsSink;


//! Helper alias for string args that are scoped.
alias StrArg = scope const(char)[];
//! Helper alias for string array args that are scoped.
alias StrArrayArg = scope const(char)[][];

/*!
 * Divide `s` into an array of `string`s.
 * ### Examples
 *     split("a=b", '=') ["a", "b"]
 *     split("a = b", '=') ["a ", " b"]
 *     split("a=b", '@') []
 */
fn split(s: StrArg, delimiter: dchar) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: string[];
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		if (decode(s, ref i) == delimiter) {
			strings ~= new string(s[base .. oldi]);
			base = i;
		}
	}
	strings ~= new string(s[base .. $]);
	return strings;
}

/*!
 * Divide `s` into an array of `string`s.
 */
fn split(s: StrArg, delimiter: StrArg) string[]
{
	strings: string[];
	do {
		i := s.indexOf(delimiter);
		if (i < 0) {
			break;
		}
		strings ~= new string(s[0 .. cast(size_t)i]);
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
			strings ~= new string(s);
		}
	}
	return strings;
}

/+ TOOD BUG
fn splitLines = mixin splitLinesTemplete!StrArg;
fn splitLines = mixin splitLinesTemplete!string;
+/

/*!
 * Get an array with an element for each line in `s`.
 * ### Example
 * ```volt
 * splitLines("a\nb\nc");  // ["a", "b", "c"]
 * ```
 */
fn splitLines(s: StrArg) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: StringsSink;
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		c := decode(s, ref i);
		if (c == '\n' || c == '\r') {
			strings.sink(new string(s[base .. oldi]));
			base = i;
			if (c == '\r' && base < s.length && s[base] == '\n') {
				base++;
				i++;
			}
		}
	}
	strings.sink(new string(s[base .. $]));
	return strings.toArray();
}

/*!
 * Get an array with an element for each line in `s`.
 * ### Example
 * ```volt
 * splitLines("a\nb\nc");  // ["a", "b", "c"]
 * ```
 */
fn splitLines(s: string) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: StringsSink;
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		c := decode(s, ref i);
		if (c == '\n' || c == '\r') {
			strings.sink(s[base .. oldi]);
			base = i;
			if (c == '\r' && base < s.length && s[base] == '\n') {
				base++;
				i++;
			}
		}
	}
	strings.sink(s[base .. $]);
	return strings.toArray();
}

/*!
 * Remove whitespace before and after `str`.
 * 
 * Whitespace is defined by @ref watt.text.ascii.isWhite.
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
	return start == stop ? null : new string(str[start .. stop]);
}

/*!
 * Remove leading whitespace from `str`.
 *
 * Whitespace is defined by @ref watt.text.ascii.isWhite.
 */
fn stripLeft(str: StrArg) string
{
	foreach (i, char c; str) {
		if (!isWhite(c)) {
			return new string(str[i .. $]);
		}
	}
	return null;
}

/*!
 * Remove trailing whitespace.
 * 
 * Whitespace is defined by @ref watt.text.ascii.isWhite.
 */
fn stripRight(str: StrArg) string
{
	foreach_reverse (i, char c; str) {
		if (!isWhite(c)) {
			return new string(str[0 .. i+1]);
		}
	}
	return null;
}

//! Count how many times `c` occurs in `s`.
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
 * Find a character in a `string`.
 *
 * @Returns The index of the first place `c` occurs in `str`,
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
 * Find a character in a `string`, starting from the end.
 *
 * @Returns The index of the last place `c` occurs in `str`, -1 otherwise.
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
 * Find a `string` in a `string`.
 *
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
 * Find a `string` in an array of `string`s.
 *
 * @Returns The index in which `s` first occurs in `ss`, or `-1`.
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
 * Replace instances of a `string` in a `string` with another.
 * @Param str The `string` to search for instances to replace.
 * @Param from The `string` to replace if found.
 * @Param to The `string` to replace `from` with.
 * @Returns A copy of `s` with occurences of `from` replaced with `to`, or `s` on its own
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

//! @Returns A non-zero value if @p str starts with one of the strings given by @p beginnings.
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

//! @Returns A non-zero value if @p str ends with one of the strings given by @p ends.
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

/*!
 * Join an array of strings into one string, separated by `sep`.
 * ### Example
 * ```volt
 * join(["a", "b"], "-");  // "a-b"
 * ```
 */
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


private:

//! Helper function, that copies a string if needed.
fn copyOrPass(str: StrArg) string
{
	return new string(str);
}

//! Helper function, that copies a string if needed.
fn copyOrPass(str: string) string
{
	return str;
}

/*!
 * Get an array with an element for each line in `s`.
 * ### Example
 * ```volt
 * splitLines("a\nb\nc");  // ["a", "b", "c"]
 * ```
 */
fn splitLinesTemplete!(T)(s: T) string[]
{
	if (s.length == 0) {
		return null;
	}
	strings: StringsSink;
	base, i, oldi: size_t;
	while (i < s.length) {
		oldi = i;
		c := decode(s, ref i);
		if (c == '\n' || c == '\r') {
			strings.sink(copyOrPass(s[base .. oldi]));
			base = i;
			if (c == '\r' && base < s.length && s[base] == '\n') {
				base++;
				i++;
			}
		}
	}
	strings.sink(copyOrPass(s[base .. $]));
	return strings.toArray();
}
