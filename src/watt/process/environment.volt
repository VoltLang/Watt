// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.environment;

version (Windows || Posix):

import core.c.string;

version (Windows) {
	import core.c.windows.windows;
	import watt.text.utf : convertUtf16ToUtf8;
}

import watt.io;
import watt.conv : toUpper;
import watt.text.string;
import watt.text.sink;


/*!
 * Returns an environment that is a copy of the running process environment.
 */
version(Posix) fn retrieveEnvironment() Environment
{
	env := new Environment();
	ptr := environ;
	for (s: char* = *ptr; s !is null; s = *(++ptr)) {
		str := s[0 .. strlen(s)];
		pos := indexOf(str, '=');
		valuePos := cast(size_t)(pos + 1);

		if (pos < 1) {
			continue;
		}

		key, value: string;

		key = new string(str[0 .. pos]);
		if (valuePos < str.length) {
			value = new string(str[valuePos .. $]);
		}

		env.set(key, value);
	}

	return env;
}

/*!
 * Returns an environment that is a copy of the running process environment.
 */
version(Windows) fn retrieveEnvironment() Environment
{
	index: size_t;
	env := new Environment();
	strs := GetEnvironmentStringsW();
	if (strs is null) {
		return env;
	}

	for (i: size_t; strs[i] != '\0'; i++) {

		keyStart := i;
		while (strs[i] != '=') { ++i; }
		keyEnd := i;

		valStart := ++i;
		while (strs[i] != '\0') { ++i; }
		valEnd := i;

		if (keyStart == keyEnd) {
			continue;
		}

		key := convertUtf16ToUtf8(strs[keyStart .. keyEnd]);
		val := convertUtf16ToUtf8(strs[valStart .. valEnd]);
		env.set(key, val);
	}

	FreeEnvironmentStringsW(strs);

	return env;
}

class Environment
{
public:
	store: string[string];


public:
	fn isSet(key: string) bool
	{
		return (toUpper(key) in store) !is null;
	}

	fn getOrNull(key: string) string
	{
		r := toUpper(key) in store;
		if (r !is null) {
			return *r;
		}
		return null;
	}

	fn set(key: string, value: string) void
	{
		store[toUpper(key)] = value;
	}

	fn remove(key: string) void
	{
		store.remove(toUpper(key));
	}
}

version (OSX) {

	//! TODO Remove this from iOS, or apps gets rejected.
	extern(C) fn _NSGetEnviron() char*** ;

	@property fn environ() char**
	{
		return *_NSGetEnviron();
	}

} else version (Posix) {

	extern extern(C) global environ: char**;

}
