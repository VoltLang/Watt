// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.file;

import watt.conv;
import watt.text.format;
import watt.text.utf;
import core.stdc.stdio;

version (Windows) import core.windows.windows;
version (Posix) import core.posix.dirent;

class FileException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

/**
 * Read the contents of the file pointed to by filename into a string with no verification.
 */
void[] read(string filename)
{
	auto cstr = filename ~ "\0";
	auto fp = fopen(cstr.ptr, "rb");
	if (fp is null) {
		throw new Exception(format("Couldn't open file '%s' for reading.", filename));
	}

	if (fseek(fp, 0, SEEK_END) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	size_t size = cast(size_t) ftell(fp);
	if (size == cast(size_t) -1) {
		throw new Exception("ftell failure.");
	}

	if (fseek(fp, 0, SEEK_SET) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	auto buf = new char[](size);
	size_t bytesRead = fread(buf.ptr, 1, size, fp);
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
bool globMatch(string path, string pattern)
{
	size_t patternIndex, pathIndex;

	while (patternIndex < pattern.length) {
		dchar patternC = decode(pattern, ref patternIndex);
		switch (patternC) {
		case '*':
			if (patternIndex + 1 >= pattern.length)
				return true;
			if (pathIndex >= path.length)
				return false;
			dchar nextPatternChar = decode(pattern, ref patternIndex);
			dchar pathC = decode(path, ref pathIndex);
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
			dchar pathC = decode(path, ref pathIndex);
			if (pathC != patternC)
				return false;
			break;
		}
	}

	return pathIndex == path.length;
}

version (Posix) void searchDir(string dirName, string glob, scope void delegate(string) dg)
{
	dirent* dp;
	auto dirp = opendir(toStringz(dirName));
	if (dirp is null) {
		throw new Exception(format("Couldn't open directory '%s'.", dirName));
	}

	do {
		dp = readdir(dirp);
		if (dp !is null) {
			auto path = toString(cast(const(char)*) dp.d_name.ptr);
			if (globMatch(path, glob)) {
				dg(path);
			}
		}
	} while (dp !is null);

	closedir(dirp);
}

version (Windows) void searchDir(string dirName, string glob, scope void delegate(string) dg)
{
	WIN32_FIND_DATA findData;
	auto handle = FindFirstFileA(toStringz(dirName ~ "/*"), &findData);  // Use our own globbing function.
	if ((cast(int) handle) == INVALID_HANDLE_VALUE) {
		auto error = GetLastError();
		if (GetLastError() == ERROR_FILE_NOT_FOUND) {
			return;
		}
		throw new Exception(format("FindFirstFile failure: %s", GetLastError()));
	}

	do {
		auto path = toString(cast(const(char)*) findData.cFileName.ptr);
		if (globMatch(toLower(path), toLower(glob))) {
			dg(toString(cast(const(char)*) findData.cFileName.ptr));
		}
		BOOL bRetval = FindNextFileA(handle, &findData);
		if (bRetval == 0) {
			auto error = GetLastError();
			if (error == ERROR_NO_MORE_FILES) {
				break;
			} else {
				throw new Exception(format("FindNextFile failure: %s", error));
			}
		}
	} while (true);
}

/**
 * Returns true if a given file exists.
 */
bool exists(const(char)[] filename)
{
	auto fp = fopen(toStringz(filename), "r");
	if (fp is null) {
		return false;
	}
	fclose(fp);
	return true;
}

/**
 * Deletes a file.
 */
void remove(const(char)[] filename)
{
	if (unlink(toStringz(filename)) != 0) {
		throw new FileException("couldn't delete file");
	}
}
