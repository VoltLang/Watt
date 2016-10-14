// Copyright © 2013-2016, Bernard Helyer.  All rights reserved.
// Copyright © 2015-2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.path;

version (Windows || Posix):

import core.exception;

version (Windows) {
	import core.windows.windows: HMODULE, DWORD, CreateDirectoryA;
	extern(C) fn _fullpath(char*, const(char)*, length: size_t) char*;
	extern(C) fn _wfullpath(wchar*, const(wchar)*, length: size_t) char*;
} else version (Posix) {
	import core.posix.sys.stat: cmkdir = mkdir, S_IRWXU, S_IRWXG, S_IRWXO;
	import core.posix.sys.types: mode_t;
	extern(C) fn realpath(const(char)*, char*) char*;
}

version (Windows) {
	extern(Windows) fn GetModuleFileNameA(HMODULE, const(char)*, DWORD) DWORD;
} else version (OSX) {
	extern(C) fn _NSGetExecutablePath(char*, u32*) i32;
} else version (Linux) {
	import core.posix.sys.types: ssize_t;
	extern(C) fn readlink(path: const(char)*, buf: char*, bufsiz: size_t) ssize_t;
} else {
	static assert(false, "unsupported platform");
}

import core.stdc.stdlib: free;
import watt.conv: toString, toStringz;
import watt.text.string: indexOf, lastIndexOf;
import watt.math.random: RandomGenerator;
import watt.process: getEnv;
import watt.io.seed: getHardwareSeedUint;
import watt.io.file: exists;
import watt.text.format : format;


/**
 * Used to seperate directory in a path.
 */
version (Windows) {
	enum string dirSeparator = "\\";
} else version (Posix) {
	enum string dirSeparator = "/";
}

/**
 * Used to seperate entries in the PATH environment variable.
 */
version (Windows) {
	enum string pathSeparator = ";";
} else version (Posix) {
	enum string pathSeparator = ":";
}

/**
 * mkdir creates a single given directory.
 *
 * Existence is not treated as failure.
 */
fn mkdir(dir: const(char)[])
{
	cstr := toStringz(dir);
	version (Windows) {
		// TODO: Unicode and error handling.
		CreateDirectoryA(cstr, null);
	} else version (Posix) {
		cmkdir(cstr, cast(mode_t)(S_IRWXU | S_IRWXG | S_IRWXO));
	}
}

/**
 * Given a path, mkdirP will create any intermediate directories that
 * need to be created -- separating the path with '/' on posix platforms,
 * '/' and '\' on Windows platforms.
 */
fn mkdirP(dir: const(char)[])
{
	for (i: size_t = 0; i < dir.length; i++) {
		if (dir[i] == '/' || dir[i] == '\\') {
			mkdir(dir[0 .. i]);
		}
	}
	mkdir(dir);
}


private fn isSlash(c: char) bool
{
	version (Windows) {
		return c == '\\' || c == '/';
	} else {
		return c == '/';
	}
}

private fn countSlashes(s: const(char)[]) size_t
{
	count: size_t;
	for (i: size_t = 0; i < s.length; ++i) {
		c := s[i];
		if (isSlash(c)) {
			count++;
		}
	}
	return count;
}

private fn removeTrailingSlashes(ref s: string)
{
	while (s.length > 0 && isSlash(s[$-1])) {
		s = s[0 .. $-1];
	}
}

/**
 * An implementation of http://pubs.opengroup.org/onlinepubs/9699919799/utilities/dirname.html,
 * with a few additions when handling drives and multiple path separator types on Windows.
 */
fn dirName(path: const(char)[]) string
{
	drive: string;
	version (Windows) if (path.length >= 2 && path[1] == ':') {
		drive = path[0 .. 2];
		path = path[2 .. $];
	}

	// 1. If the string is //,  skip steps 2 to 5.
	if (path.length >= 2 && isSlash(path[0]) && isSlash(path[1])) {
		return format("%s%s", drive, dirSeparator);
	}

	/* 2. If string consists entirely of <slash> characters, 
	 * set string to a single <slash> and skip steps 3 to 8. */
	count := countSlashes(path);
	if (count == path.length) {
		return format("%s%s", drive, dirSeparator);
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
		return format("%s%s", drive, dirSeparator);
	}

	return format("%s%s", drive, path);
}

/**
 * An implementation of http://pubs.opengroup.org/onlinepubs/9699919799/utilities/basename.html.
 * with a few additions when handling drives and multiple path separator types on Windows.
 */
fn baseName(path: const(char)[], suffix: const(char)[] = "") string
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

	slashesCount := countSlashes(path);
	if (countSlashes(path) == path.length) {
		return dirSeparator;
	}

	removeTrailingSlashes(ref path);

	slashIndex := path.indexOf(dirSeparator[0]);
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

fn extension(path: const(char)[]) string
{
	i := lastIndexOf(path, '.');
	if (i <= 0) {
		return null;
	}

	return new string(path[i .. $]);
}

fn temporaryFilename(extension: string = "", subdir: string = "") string
{
	rng: RandomGenerator;
	rng.seed(getHardwareSeedUint());
	version (Windows) {
		prefix: string = format("%s/", getEnv("TEMP"));
	} else {
		prefix: string = "/tmp/";
	}

	if (subdir != "") {
		prefix = format("%s%s/", prefix, subdir);
		mkdir(prefix);
	}

	filename: string;
	do {
		filename = rng.randomString(32);
		filename = format("%s%s%s", prefix, filename, extension);
	} while (exists(filename));

	return filename;
}

fn fullPath(file: string) string
{
	version (Posix) {
		result := realpath(toStringz(file), null);
	} else version (Windows) {
		result := _fullpath(null, toStringz(file), 0);
	}

	ret := toString(result);
	free(cast(void*)result);

	return ret;
}

/**
 * Return the path to the dir that the executable is in.
 */
fn getExecDir() string
{
	stack: char[512];
	version (Windows) {

		ret := GetModuleFileNameA(null, stack.ptr, 512);

	} else version (Linux) {

		ret := readlink("/proc/self/exe", stack.ptr, 512);

	} else version (OSX) {

		size := cast(u32)stack.length;
		ret := _NSGetExecutablePath(stack.ptr, &size);

		if (ret != 0 || size == 0) {
			ret = -1;
		} else {
			ret = cast(i32)size;
		}

	} else {

		static assert(false);

	}

	if (ret < 1) {
		throw new Exception("could not get exe path");
	}

	return new string(dirName(stack[0 .. cast(size_t)ret]));
}
