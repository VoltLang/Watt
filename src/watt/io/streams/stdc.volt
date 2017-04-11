// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.streams.stdc;

version (CRuntime_All):

import core.c.stdio: FILE, fopen, fclose, fputc, fwrite,
                     fflush, feof, fgetc, ungetc, fread;
import watt.conv : toStringz;
import watt.io.streams : OutputStream, InputStream;


/**
 * An OutputStream in which the sink is a file.
 */
class OutputStdcStream : OutputStream
{
public:
	handle: FILE*;


public:
	this(filename: const(char)[])
	{
		if (filename.length > 0u) {
			handle = fopen(toStringz(filename), "w".ptr);
		}
	}

	override fn close()
	{
		if (handle !is null) {
			fclose(handle);
			handle = null;
		}
	}

	@property override fn isOpen() bool
	{
		return handle !is null;
	}

	override fn put(c: dchar)
	{
		fputc(cast(i32) c, handle);
	}

	override fn write(s: const(char)[])
	{
		fwrite(cast(void*)s.ptr, 1, s.length, handle);
	}

	override fn flush()
	{
		fflush(handle);
	}
}

/**
 * An InputStream in which the source is a file.
 */
class InputStdcStream : InputStream
{
public:
	handle: FILE*;


public:
	this(filename: const(char)[])
	{
		if (filename.length > 0u) {
			handle = fopen(toStringz(filename), "r".ptr);
		}
	}

	override fn close()
	{
		if (handle !is null) {
			fclose(handle);
			handle = null;
		}
	}

	@property override fn isOpen() bool
	{
		return handle !is null;
	}

	override fn get() dchar
	{
		return cast(dchar) fgetc(handle);
	}

	override fn read(buffer: u8[]) u8[]
	{
		num: size_t = fread(cast(void*)buffer.ptr, 1, buffer.length, handle);
		if (num != buffer.length) {
			return buffer[0..num];
		}
		return buffer;
	}

	override fn eof() bool
	{
		return feof(handle) != 0;
	}
}
