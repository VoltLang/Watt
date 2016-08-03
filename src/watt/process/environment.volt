// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.environment;

version (Windows || Posix):

import core.stdc.string;

import watt.io;
import watt.text.string;
import watt.text.sink;


/**
 * Returns a environment that is a copy of the running process environment.
 */
version(Posix) fn retriveEnvironment() Environment
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

/**
 * Returns a environment that is a copy of the running process environment.
 */
version(Windows) fn retriveEnvironment() Environment
{
	// This is a stub
	return new Environment();
}

class Environment
{
public:
	store: string[string];


public:
	fn isSet(key: string) bool
	{
		return (key in store) !is null;
	}

	fn getOrNull(key: string) string
	{
		r := key in store;
		if (r !is null) {
			return *r;
		}
		return null;
	}

	fn set(key: string, value: string) void
	{
		store[key] = value;
	}

	fn remove(key: string) void
	{
		store.remove(key);
	}
}

version (OSX) {

	/// TODO Remove this from iOS, or apps gets rejected.
	extern(C) fn _NSGetEnviron() char*** ;

	@property fn environ() char**
	{
		return *_NSGetEnviron();
	}

} else version (Posix) {
	extern extern(C) global environ: char**;
}
