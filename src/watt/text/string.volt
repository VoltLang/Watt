// Copyright © 2014-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
// String utilities.
module watt.text.string;

import core.exception;
import watt.text.ascii: isWhite;
import watt.text.utf;


/**
 * Split string s by a given delimiter.
 * Examples:
 *   split("a=b", '=') ["a", "b"]
 *   split("a = b", '=') ["a ", " b"]
 *   split("a=b", '@') []
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

/**
 * Split string s by \n, \r, and \r\n.
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

/**
 * Remove whitespace before and after, as defined by watt.ascii.isWhite.
 * Examples:
 *   strip("  apple  ") -> "apple"
 *   strip("  apple  pie  ") -> "apple pie"
 */
fn strip(str: const(char)[]) string
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
	return start == stop ? null: str[start .. stop];
}

/**
 * Remove leading whitespace, as defined by watt.ascii.isWhite.
 */
fn stripLeft(str: const(char)[]) string
{
	foreach (i, dchar c; str) {
		if (!isWhite(c)) {
			return str[i .. $];
		}
	}
	return str;
}

/**
 * Remove trailing whitespace, as defined by watt.ascii.isWhite.
 */
fn stripRight(str: string) string
{
	foreach_reverse (i, dchar c; str) {
		if (!isWhite(c)) {
			return str[0 .. i+1];
		}
	}
	return str;
}

/// Returns how many times c occurs in s.
fn count(str: string, c: dchar) size_t
{
	n, i: size_t;
	while (i < str.length) {
		if (decode(str, ref i) == c) {
			n++;
		}
	}
	return n;
}

/**
 * Returns the index of the first place c occurs in str,
 * or -1 if it doesn't occur.
 */
fn indexOf(str: const(char)[], c: dchar) ptrdiff_t
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

/**
 * Returns the index of the last place c occurs in str,
 * or -1 otherwise.
 */
fn lastIndexOf(str: const(char)[], c: dchar) ptrdiff_t
{
	foreach_reverse (i, dchar e; str) {
		if (e == c) {
			return cast(ptrdiff_t)i;
		}
	}
	return -1;
}

/**
 * If the substring sub occurs in s, returns the index where it occurs.
 * Otherwise, it returns -1.
 */
fn indexOf(str: const(char)[], sub: const(char)[]) ptrdiff_t
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

/**
 * Returns the index in which s first occurs in ss, or -1.
 */
fn indexOf(ss: const(char)[][], str: const(char)[]) ptrdiff_t
{
	foreach (i, e; ss) {
		if (e == str) {
			return cast(ptrdiff_t)i;
		}
	}
	return -1;
}

/**
 * Returns a copy of s with occurences of from replaced with to, or s if nothing from does not occur.
 */
fn replace(str: const(char)[], from: const(char)[], to: const(char)[]) string
{
	if (from == to) {
		throw new Exception("replace: from and to cannot match!");
	}
	result := new string(str);
	i := indexOf(result, from);
	while (i != -1) {
		si := cast(size_t) i;
		result = result[0 .. si] ~ to ~ result[si + from.length .. $];
		i = indexOf(result, from);
	}
	return result;
}


fn startsWith(str: const(char)[], beginnings: const(char)[][]...) int
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

fn endsWith(str: const(char)[], ends: const(char)[][]...) int
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

/// Join an array of strings into one, separated by sep.
fn join(ss: const(char)[][], sep: const(char)[] = "") string
{
	outs: string;
	foreach (i, e; ss) {
		outs ~= e;
		if (i < ss.length - 1) {
			outs ~= sep;
		}
	}
	return outs;
}
