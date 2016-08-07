// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.environment;

version (Windows || Posix):

import core.stdc.string;

version (Windows) {
	import core.windows.windows;
}

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

		key := convert16To8(strs[keyStart .. keyEnd]);
		val := convert16To8(strs[valStart .. valEnd]);
		env.store[key] = val;
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

} else version (Windows) {

	immutable(wchar)[] convert8To16(const(char)[] str)
	{
		if (str.length == 0) {
			return null;
		}

		srcNum := cast(int)str.length;
		dstNum := MultiByteToWideChar(CP_UTF8, 0, str.ptr, srcNum, null, 0);
		w := new wchar[](dstNum+1);

		dstNum = MultiByteToWideChar(CP_UTF8, 0,
			str.ptr, -1, w.ptr, dstNum);
		w[dstNum] = 0;
		w = w[0 .. dstNum];
		return cast(immutable(wchar)[])w;
	}

	string convert16To8(const(wchar)[] w)
	{
		if (w.length == 0) {
			return null;
		}

		srcNum := cast(int)w.length;
		dstNum := WideCharToMultiByte(CP_UTF8, 0, w.ptr, srcNum, null, 0, null, null);
		str := new char[](dstNum+1);

		dstNum = WideCharToMultiByte(CP_UTF8, 0,
			w.ptr, srcNum, str.ptr, dstNum, null, null);
		str[dstNum] = 0;
		str = str[0 .. dstNum];
		return cast(string)str;
	}

}
