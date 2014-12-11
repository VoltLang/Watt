// Copyright © 2014-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
// String utilities.
module watt.text.string;

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

