// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.path;

import core.stdc.stdio;
version (Windows) {
	import core.windows.windows;
} else version (Posix) {
	import core.posix.sys.stat : cmkdir = mkdir, S_IRWXU, S_IRWXG, S_IRWXO;
	import core.posix.sys.types;
} else version (Emscripten) {
	// Nothing
} else {
	static assert(false);
}

version (Windows) global const string dirSeparator = "\\";
else global const string dirSeparator = "/";

/**
 * mkdir creates a single given directory.
 *
 * Existence is not treated as failure.
 */
void mkdir(const(char)[] dir)
{
	auto cstr = dir ~ "\0";
	version (Windows) {
		// TODO: Unicode and error handling.
		CreateDirectoryA(cstr.ptr, null);
	} else version (Posix) {
		cmkdir(cstr.ptr, cast(mode_t)(S_IRWXU | S_IRWXG | S_IRWXO));
	}
	return;
}

/**
 * Given a path, mkdirP will create any intermediate directories that
 * need to be created -- separating the path with '/' on posix platforms,
 * '/' and '\' on Windows platforms.
 */
void mkdirP(const(char)[] dir)
{
	for (size_t i = 0; i < dir.length; i++) {
		if (dir[i] == '/' || dir[i] == '\\') {
			mkdir(dir[0 .. i]);
		}
	}
	mkdir(dir);
	return;
}

/**
 * An implementation of http://pubs.opengroup.org/onlinepubs/9699919799/utilities/dirname.html,
 * with a few additions when handling drives and multiple path separator types on Windows.
 */
string dirName(const(char)[] path)
{
	string drive;
	version (Windows) if (path.length >= 2 && path[1] == ':') {
		drive = path[0 .. 2];
		path = path[2 .. $];
	}

	bool isSlash(char c)
	{
		version (Windows) {
			return c == '\\' || c == '/';
		} else {
			return c == '/';
		}
	}

	size_t countSlashes()
	{
		size_t count;
		for (size_t i = 0; i < path.length; ++i) {
			auto c = path[i];
			if (isSlash(c)) {
				count++;
			}
		}
		return count;
	}

	void removeTrailingSlashes()
	{
		while (path.length > 0 && isSlash(path[$-1])) {
			path = path[0 .. $-1];
		}
	}

	// 1. If the string is //,  skip steps 2 to 5.
	if (path.length >= 2 && isSlash(path[0]) && isSlash(path[1])) {
		return drive ~ dirSeparator;
	}

	/* 2. If string consists entirely of <slash> characters, 
	 * set string to a single <slash> and skip steps 3 to 8. */
	auto count = countSlashes();
	if (count == path.length) {
		return drive ~ dirSeparator;
	}

	// 3. If there are any trailing <slash> characters, they shall be removed.
	removeTrailingSlashes();

	// 4. If there are no <slash> characters remaining in string, skip 5 to 8 and set it to ".".
	count = countSlashes();
	if (count == 0) {
		version (Windows) return drive;
		else return ".";
	}

	// 5. If there are any non-slash characters trailing, they shall be removed.
	while (path.length > 0 && !isSlash(path[$-1])) {
		path = path[0 .. $-1];
	}

	// 7. If there are any trailing <slash> characters in string, they shall be removed.
	removeTrailingSlashes();

	// 8. If the remaining string is empty, string shall be set to a single <slash> character.
	if (path.length == 0) {
		return drive ~ dirSeparator;
	}

	return drive ~ path;
}
