// Copyright © 2014-2015, Bernard Helyer.  // See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
// String utilities.
module watt.text.string;

import watt.text.ascii : isWhite;
import watt.text.utf;

/**
 * Split string s by a given delimiter.
 * Examples:
 *   split("a=b", '=') ["a", "b"]
 *   split("a = b", '=') ["a ", " b"]
 *   split("a=b", '@') []
 */
string[] split(string s, dchar delimiter)
{
	if (s.length == 0) {
		return null;
	}
	string[] strings;
	size_t base, i, oldi;
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
string[] splitLines(string s)
{
	if (s.length == 0) {
		return null;
	}
	string[] strings;
	size_t base, i, oldi;
	while (i < s.length) {
		oldi = i;
		auto c = decode(s, ref i);
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
string strip(const(char)[] str)
{
	size_t start = 0;
	size_t stop = str.length;
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

/**
 * Remove leading whitespace, as defined by watt.ascii.isWhite.
 */
string stripLeft(const(char)[] str)
{
	foreach (i, c; str) {
		if (!isWhite(c)) {
			return str[i .. $];
		}
	}
	return str;
}

/**
 * Remove trailing whitespace, as defined by watt.ascii.isWhite.
 */
string stripRight(string str)
{
	foreach_reverse (i, c; str) {
		if (!isWhite(c)) {
			return str[0 .. i+1];
		}
	}
	return str;
}

/// Returns how many times c occurs in s.
size_t count(string s, dchar c)
{
	size_t n, i;
	while (i < s.length) {
		if (decode(s, ref i) == c) {
			n++;
		}
	}
	return n;
}

/**
 * Returns the index of the first place c occurs in str,
 * or -1 if it doesn't occur.
 */
ptrdiff_t indexOf(const(char)[] s, dchar c)
{
	size_t i, oldi;
	while (i < s.length) {
		oldi = i;
		if (decode(s, ref i) == c) {
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
ptrdiff_t lastIndexOf(const(char)[] s, dchar c)
{
	foreach_reverse (i, e; s) {
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
ptrdiff_t indexOf(const(char)[] s, const(char)[] sub)
{
	if (sub.length == 0) {
		return -1;
	}
	size_t i;
	while (i < s.length) {
		auto remaining = s.length - i;
		if (remaining < sub.length) {
			return -1;
		}
		if (s[i .. i + sub.length] == sub) {
			if (i >= ptrdiff_t.max) {
				throw new Exception("indexOf: string to big.");
			}
			return cast(ptrdiff_t) i;
		}
		decode(s, ref i);
	}
	return -1;
}

/**
 * Returns the index in which s first occurs in ss, or -1.
 */
ptrdiff_t indexOf(const(char)[][] ss, const(char)[] s)
{
	foreach (i, e; ss) {
		if (e == s) {
			return cast(ptrdiff_t)i;
		}
	}
	return -1;
}

/**
 * Returns a copy of s with occurences of from replaced with to, or s if nothing from does not occur.
 */
string replace(const(char)[] s, const(char)[] from, const(char)[] to)
{
	if (from == to) {
		throw new Exception("replace: from and to cannot match!");
	}
	string result = s;
	auto i = indexOf(result, from);
	while (i != -1) {
		auto si = cast(size_t) i;
		result = result[0 .. si] ~ to ~ result[si + from.length .. $];
		i = indexOf(result, from);
	}
	return result;
}

int startsWith(const(char)[] s, const(char)[][] beginnings...)
{
	int result;
	foreach (beginning; beginnings) {
		if (beginning.length > s.length) {
			continue;
		}
		if (s[0 .. beginning.length] == beginning) {
			result++;
		}
	}
	return result;
}

int endsWith(const(char)[] s, const(char)[][] ends...)
{
	int result;
	foreach (end; ends) {
		if (end.length > s.length) {
			continue;
		}
		if (s[$ - end.length .. $] == end) {
			result++;
		}
	}
	return result;
}

/// Join an array of strings into one, separated by sep.
string join(const(char)[][] ss, const(char)[] sep="")
{
	string outs;
	foreach (i, e; ss) {
		outs ~= e;
		if (i < ss.length - 1) {
			outs ~= sep;
		}
	}
	return outs;
}
