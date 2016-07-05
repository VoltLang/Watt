// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.environment;

import core.stdc.string;

import watt.io;
import watt.text.string;
import watt.text.sink;


/**
 * Returns a environment that is a copy of the running process environment.
 */
version(Posix) Environment retriveEnvironment()
{
	env := new Environment();
	ptr := environ;
	for (auto s = *ptr; s !is null; s = *(++ptr)) {
		str := s[0 .. strlen(s)];
		pos := indexOf(str, '=');
		valuePos := cast(size_t)(pos + 1);

		if (pos < 1) {
			continue;
		}

		key, value : string;

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
version(Windows) Environment retriveEnvironment()
{
	// This is a stub
	return new Environment();
}

class Environment
{
public:
	string[string] store;


public:
	bool isSet(string key)
	{
		return (key in store) !is null;
	}

	string getOrNull(string key)
	{
		r := key in store;
		if (r !is null) {
			return *r;
		}
		return null;
	}

	void set(string key, string value)
	{
		store[key] = value;
	}

	void remove(string key)
	{
		store.remove(key);
	}
}

version (OSX) {

	/// TODO Remove this from iOS, or apps gets rejected.
	extern(C) char*** _NSGetEnviron();

	@property char** environ()
	{
		return *_NSGetEnviron();
	}

} else version (Posix) {
	extern extern(C) global char** environ;
}
