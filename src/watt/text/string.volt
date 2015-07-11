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
 * Remove whitespace before and after, as defined by watt.ascii.isWhite.
 * Examples:
 *   strip("  apple  ") -> "apple"
 *   strip("  apple  pie  ") -> "apple pie"
 */
string strip(string str)
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
 * Returns the index of the first place c occurs in str,
 * or -1 if it doesn't occur.
 */
ptrdiff_t indexOf(string s, dchar c)
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
 * If the substring sub occurs in s, returns the index where it occurs.
 * Otherwise, it returns -1.
 */
ptrdiff_t indexOf(string s, string sub)
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
 * Returns a copy of s with occurences of from replaced with to, or s if nothing from does not occur.
 */
string replace(string s, string from, string to)
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

int startsWith(string s, string[] beginnings...)
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

int endsWith(string s, string[] ends...)
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

