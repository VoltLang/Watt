// Copyright © 2013-2017, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Simple filesystem operation functions.
 *
 * Functions for reading an entire file into memory, to check if a file exists,
 * for deleting a file, searching a directory for a file, and so on.
 */
module watt.io.file;

import core.exception;
import core.c.stdio;
import watt.conv;
import watt.text.format;
import watt.text.utf;

version (Windows) {
	import core.c.windows.windows;
} else version (Posix) {
	import core.c.posix.dirent;
	import core.c.posix.sys.stat;
}


/*!
 * An `Exception` thrown upon failure of this module's functions.
 */
class FileException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

/*!
 * Read a file into an array.  
 * Read the contents of the file pointed to by `filename` into a `void[]` array.
 * The intepretation is left up to the caller.
 *
 * For example, if you want to treat the data as a string:
 * ```volt
 * str := cast(string)read("file.txt");
 * ```
 *
 * The entire file is read into memory at once, so be wary of using this function for
 * very large files.
 * @Param filename The filename to read.
 * @Returns The entire contents of the file.
 * @Throws `FileException` If the file cannot be read.
 */
fn read(filename: string) void[]
{
	if (!isFile(filename)) {
		return null;
	}
	cstr := toStringz(filename);
	fp := fopen(cstr, "rb");
	if (fp is null) {
		throw new FileException(format("Couldn't open file '%s' for reading.", filename));
	}

	if (fseek(fp, 0, SEEK_END) != 0) {
		fclose(fp);
		throw new FileException("fseek failure.");
	}

	size: size_t = cast(size_t) ftell(fp);
	if (size == cast(size_t) -1) {
		throw new FileException("ftell failure.");
	}

	if (fseek(fp, 0, SEEK_SET) != 0) {
		fclose(fp);
		throw new FileException("fseek failure.");
	}

	buf := new char[](size);
	bytesRead: size_t = fread(cast(void*)buf.ptr, 1, size, fp);
	if (bytesRead != size) {
		throw new FileException("read failure.");
	}

	fclose(fp);

	return cast(void[]) buf;
}

/*!
 * Check if `path` matches `pattern`.  
 * `pattern` is treated as a regular string except for two special characters:
 * - `*` matches zero or more characters.
 * - `?` matches a single character.
 * ### Examples
 * ```volt
 * globMatch("file.txt", "file.txt");       // true
 * globMatch("file.txt", "file.txtextra");  // false
 * globMatch("file.txt", "*.txt");          // true
 * globMatch("file.txt", "*.???");          // true
 * globMatch("file.txt", "*.??");           // false
 * ```
 * @Returns `true` if `pattern` matches `path`.
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

/*!
 * Call a delegate for file in a directory that matches a given pattern.  
 * @Param dirName The directory to search the contents of.
 * @Param glob The pattern to check every entry in `dirName` against.
 * The matching rules are the same as the `pattern` parameter of
 * the `globMatch` function.
 * @Param dgt A delegate that is called with every path in `dirName` that
 * matches `glob`.
 * @Throws `FileException` If `dirName` could not be opened or read.
 */
fn searchDir(dirName: string, glob: string, dgt: scope dg(string))
{
	searchDirImpl(dirName, glob, dgt);
}

private version (Posix) fn searchDirImpl(dirName: string, glob: string, dgt: scope dg (string))
{
	dp: dirent*;
	dirp := opendir(toStringz(dirName));
	if (dirp is null) {
		throw new FileException(format("Couldn't open directory '%s'.", dirName));
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

private version (Windows) fn searchDirImpl(dirName: string, glob: string, dgt: scope dg (string))
{
	findData: WIN32_FIND_DATA;
	handle := FindFirstFileA(toStringz(format("%s/*", dirName)), &findData);  // Use our own globbing function.
	if ((cast(i32) handle) == INVALID_HANDLE_VALUE) {
		error := GetLastError();
		if (GetLastError() == ERROR_FILE_NOT_FOUND) {
			return;
		}
		throw new FileException(format("FindFirstFile failure: %s", GetLastError()));
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
				throw new FileException(format("FindNextFile failure: %s", error));
			}
		}
	} while (true);
}

/*!
 * Is a given path a file?  
 * For example, a directory would not be classified as a file.
 * @Returns `true` if `path` points to a file.
 */
fn isFile(path: scope const(char)[]) bool
{
	return exists(path) && !isDir(path);
}

/*!
 * Is a given path a directory?  
 * For example, a file is not a directory.
 * @Returns `true` if `path` points to a directory.
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

/*!
 * Does a given path exist?
 * @Returns `true` if `path` exists.
 */
fn exists(path: const(char)[]) bool
{
	fp := fopen(toStringz(path), "r");
	if (fp is null) {
		return false;
	}
	fclose(fp);
	return true;
}

/*!
 * Delete a file pointed to by a given path.
 *
 * This could fail for a number of reasons.  
 * As the functions in this module are intended to be simple,
 * more detailed failure information is not available. If you need
 * more information, use the functions provided by your operating system.
 * @Throws `FileException` if the file could not be deleted for some reason.
 */
fn remove(path: const(char)[])
{
	if (unlink(toStringz(path)) != 0) {
		throw new FileException("couldn't delete file");
	}
}
