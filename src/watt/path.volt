// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.path;

import watt.text.string : indexOf, lastIndexOf;
import watt.math.random : RandomGenerator;
import watt.process : getEnv;
import watt.io.seed: getHardwareSeedUint;
import watt.io.file : exists;
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
version (Windows) {
	extern(Windows) DWORD GetModuleFileNameA(HMODULE, const(char)*, DWORD);
} else version (OSX) {
	extern(C) int _NSGetExecutablePath(char*, uint*);
} else version (Linux) {
	import core.posix.sys.types : ssize_t;
	extern(C) ssize_t readlink(const(char)* path, char* buf, size_t bufsiz);
}


version (Windows) {
	enum string dirSeparator = "\\";
} else version (Posix || Emscripten) {
	enum string dirSeparator = "/";
} else {
	static assert(false, "not a supported platform");
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
}


private bool isSlash(char c)
{
	version (Windows) {
		return c == '\\' || c == '/';
	} else {
		return c == '/';
	}
}

private size_t countSlashes(const(char)[] s)
{
	size_t count;
	for (size_t i = 0; i < s.length; ++i) {
		auto c = s[i];
		if (isSlash(c)) {
			count++;
		}
	}
	return count;
}

private void removeTrailingSlashes(ref string s)
{
	while (s.length > 0 && isSlash(s[$-1])) {
		s = s[0 .. $-1];
	}
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

	// 1. If the string is //,  skip steps 2 to 5.
	if (path.length >= 2 && isSlash(path[0]) && isSlash(path[1])) {
		return drive ~ dirSeparator;
	}

	/* 2. If string consists entirely of <slash> characters, 
	 * set string to a single <slash> and skip steps 3 to 8. */
	auto count = countSlashes(path);
	if (count == path.length) {
		return drive ~ dirSeparator;
	}

	// 3. If there are any trailing <slash> characters, they shall be removed.
	removeTrailingSlashes(ref path);

	// 4. If there are no <slash> characters remaining in string, skip 5 to 8 and set it to ".".
	count = countSlashes(path);
	if (count == 0) {
		if (drive.length > 0) {
			return drive;
		}
		return ".";
	}

	// 5. If there are any non-slash characters trailing, they shall be removed.
	while (path.length > 0 && !isSlash(path[$-1])) {
		path = path[0 .. $-1];
	}

	// 7. If there are any trailing <slash> characters in string, they shall be removed.
	removeTrailingSlashes(ref path);

	// 8. If the remaining string is empty, string shall be set to a single <slash> character.
	if (path.length == 0) {
		return drive ~ dirSeparator;
	}

	return drive ~ path;
}

/**
 * An implementation of http://pubs.opengroup.org/onlinepubs/9699919799/utilities/basename.html.
 * with a few additions when handling drives and multiple path separator types on Windows.
 */
string baseName(const(char)[] path, const(char)[] suffix="")
{
	// Omit drive letters.
	version (Windows) {
		if (path.length > 2 && path[1] == ':') {
			path = path[2 .. $];
		}
	}

	if (path.length == 0) {
		return "";
	}

	auto slashesCount = countSlashes(path);
	if (countSlashes(path) == path.length) {
		return dirSeparator;
	}

	removeTrailingSlashes(ref path);

	auto slashIndex = path.indexOf(dirSeparator[0]);
	while (slashIndex >= 0) {
		path = path[slashIndex+1 .. $];
		slashIndex = path.indexOf(dirSeparator[0]);
	}

	if (suffix == path || path.length <= suffix.length || path[($-suffix.length) .. $] != suffix) {
		return path;
	}

	path = path[0 .. ($-suffix.length)];
	return path;
}

string extension(const(char)[] path)
{
	auto i = lastIndexOf(path, '.');
	if (i <= 0) {
		return null;
	}

	return new string(path[i .. $]);
}

string temporaryFilename(string extension="", string subdir="")
{
	RandomGenerator rng;
	rng.seed(getHardwareSeedUint());
	version (Windows) {
		string prefix = getEnv("TEMP") ~ '/';
	} else {
		string prefix = "/tmp/";
	}

	if (subdir != "") {
		prefix ~= subdir ~ "/";
		mkdir(prefix);
	}

	string filename;
	do {
		filename = rng.randomString(32);
		filename = prefix ~ filename ~ extension;
	} while (exists(filename));

	return filename;
}

/**
 * Return the path to the dir that the executable is in.
 */
string getExecDir()
{
	char[512] stack;
	version (Windows) {

		auto ret = GetModuleFileNameA(null, stack.ptr, 512);

	} else version (Linux) {

		auto ret = readlink("/proc/self/exe", stack.ptr, 512);

	} else version (OSX) {

		uint size = cast(uint)stack.length;
		auto ret = _NSGetExecutablePath(stack.ptr, &size);

		if (ret != 0 || size == 0) {
			ret = -1;
		} else {
			ret = cast(int)size;
		}

	} else version (Emscripten) {

		int ret = 0;

	} else {

		static assert(false);

	}

	if (ret < 1) {
		throw new Exception("could not get exe path");
	}

	return new string(dirName(stack[0 .. cast(size_t)ret]));
}
