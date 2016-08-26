// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.file;

import core.exception;
import core.stdc.stdio;
import watt.conv;
import watt.text.format;
import watt.text.utf;

version (Windows) {
	import core.windows.windows;
} else version (Posix) {
	import core.posix.dirent;
	import core.posix.sys.stat;
}


class FileException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

/**
 * Read the contents of the file pointed to by filename into a string with no verification.
 */
fn read(filename: string) void[]
{
	if (!isFile(filename)) {
		return null;
	}
	cstr := toStringz(filename);
	fp := fopen(cstr, "rb");
	if (fp is null) {
		throw new Exception(format("Couldn't open file '%s' for reading.", filename));
	}

	if (fseek(fp, 0, SEEK_END) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	size: size_t = cast(size_t) ftell(fp);
	if (size == cast(size_t) -1) {
		throw new Exception("ftell failure.");
	}

	if (fseek(fp, 0, SEEK_SET) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	buf := new char[](size);
	bytesRead: size_t = fread(cast(void*)buf.ptr, 1, size, fp);
	if (bytesRead != size) {
		throw new Exception("read failure.");
	}

	fclose(fp);

	return cast(void[]) buf;
}

/**
 * Returns true if path matches pattern.
 *
 * Supports '*' and '?' wild cards. '*' matches zero or more characters, and '?' matches a single character.
 */
fn globMatch(path: string, pattern: string) bool
{
	patternIndex, pathIndex: size_t;

	while (patternIndex < pattern.length) {
		patternC: dchar = decode(pattern, ref patternIndex);
		switch (patternC) {
		case '*':
			if (patternIndex + 1 >= pattern.length)
				return true;
			if (pathIndex >= path.length)
				return false;
			nextPatternChar: dchar = decode(pattern, ref patternIndex);
			pathC: dchar = decode(path, ref pathIndex);
			if (nextPatternChar == '*') {
				if (pathC != patternC) {
					return false;
				}
				break;
			}
			while (pathC != nextPatternChar) {
				if (pathIndex >= path.length) {
					return false;
				}
				pathC = decode(path, ref pathIndex);
			}
			break;
		case '?':
			if (pathIndex >= path.length)
				return false;
			decode(path, ref pathIndex);
			break;
		default:
			if (pathIndex >= path.length)
				return false;
			pathC: dchar = decode(path, ref pathIndex);
			if (pathC != patternC)
				return false;
			break;
		}
	}

	return pathIndex == path.length;
}

version (Posix) fn searchDir(dirName: string, glob: string, dgt: scope void delegate(string))
{
	dp: dirent*;
	dirp := opendir(toStringz(dirName));
	if (dirp is null) {
		throw new Exception(format("Couldn't open directory '%s'.", dirName));
	}

	do {
		dp = readdir(dirp);
		if (dp !is null) {
			path := toString(cast(const(char)*) dp.d_name.ptr);
			if (globMatch(path, glob)) {
				dgt(path);
			}
		}
	} while (dp !is null);

	closedir(dirp);
}

version (Windows) fn searchDir(dirName: string, glob: string, dgt: scope void delegate(string))
{
	findData: WIN32_FIND_DATA;
	handle := FindFirstFileA(toStringz(format("%s/*", dirName)), &findData);  // Use our own globbing function.
	if ((cast(i32) handle) == INVALID_HANDLE_VALUE) {
		error := GetLastError();
		if (GetLastError() == ERROR_FILE_NOT_FOUND) {
			return;
		}
		throw new Exception(format("FindFirstFile failure: %s", GetLastError()));
	}

	do {
		path := toString(cast(const(char)*) findData.cFileName.ptr);
		if (globMatch(toLower(path), toLower(glob))) {
			dgt(toString(cast(const(char)*) findData.cFileName.ptr));
		}
		bRetval: BOOL = FindNextFileA(handle, &findData);
		if (bRetval == 0) {
			error := GetLastError();
			if (error == ERROR_NO_MORE_FILES) {
				break;
			} else {
				throw new Exception(format("FindNextFile failure: %s", error));
			}
		}
	} while (true);
}

/**
 * Returns true if a path exists and is not a directory.
 */
fn isFile(path: scope const(char)[]) bool
{
	return exists(path) && !isDir(path);
}

/**
 * Returns true if a given directory exists.
 */
fn isDir(path: scope const(char)[]) bool
{
	version (Windows) {
		attr: DWORD = GetFileAttributesA(toStringz(path));
		if (attr == INVALID_FILE_ATTRIBUTES) {
			return false;
		}

		return (attr & FILE_ATTRIBUTE_DIRECTORY) != 0;	
	} else version (Posix) {
		buf: stat_t;

		if (stat(toStringz(path), &buf) != 0) {
			return false;
		}

		return (buf.st_mode & S_IFMT) == S_IFDIR;
	} else {
		return false;
	}
}

/**
 * Returns true if a given file exists.
 */
fn exists(filename: const(char)[]) bool
{
	fp := fopen(toStringz(filename), "r");
	if (fp is null) {
		return false;
	}
	fclose(fp);
	return true;
}

/**
 * Deletes a file.
 */
fn remove(filename: const(char)[])
{
	if (unlink(toStringz(filename)) != 0) {
		throw new FileException("couldn't delete file");
	}
}
