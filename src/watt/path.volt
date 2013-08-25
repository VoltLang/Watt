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
