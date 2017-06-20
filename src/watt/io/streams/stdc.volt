// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Stream implementations in which the underlying implementation is libc FILEs.
module watt.io.streams.stdc;

version (CRuntime_All):

import core.c.stdio: FILE, fopen, fclose, fputc, fwrite,
                     fflush, feof, fgetc, ungetc, fread;
import watt.conv : toStringz;
import watt.io.streams : OutputStream, InputStream;


/*!
 * An OutputStream in which the sink is a file.
 */
class OutputStdcStream : OutputStream
{
public:
	//! The underlying FILE handle.
	handle: FILE*;


public:
	/*!
	 * Construct a new @p OutputStdcStream from a filename.
	 * This will use the mode string "w", so will overwrite
	 * any file with the given name that already exists.
	 */
	this(filename: const(char)[])
	{
		if (filename.length > 0u) {
			handle = fopen(toStringz(filename), "w".ptr);
		}
	}

	/*!
	 * Construct a new @p OutputStdcStream with a filename, using
	 * the given mode string.
	 */
	this(filename: const(char)[], flags: const(char)[])
	{
		if (filename.length > 0u) {
			handle = fopen(toStringz(filename), toStringz(flags));
		}
	}

	//! Close the underlying FILE handle.
	override fn close()
	{
		if (handle !is null) {
			fclose(handle);
			handle = null;
		}
	}

	//! Is this stream open?
	@property override fn isOpen() bool
	{
		return handle !is null;
	}

	//! Write a single character to the stream.
	override fn put(c: dchar)
	{
		fputc(cast(i32) c, handle);
	}

	//! Write a string to the stream.
	override fn write(s: scope const(char)[])
	{
		fwrite(cast(void*)s.ptr, 1, s.length, handle);
	}

	//! Ensure all buffered input is written to the stream.
	override fn flush()
	{
		fflush(handle);
	}
}

/*!
 * An InputStream in which the source is a file.
 */
class InputStdcStream : InputStream
{
public:
	//! The underlying FILE handle.
	handle: FILE*;


public:
	//! Construct a new stream from a filename.
	this(filename: const(char)[])
	{
		if (filename.length > 0u) {
			handle = fopen(toStringz(filename), "r".ptr);
		}
	}

	//! Close the underlying FILE handle.
	override fn close()
	{
		if (handle !is null) {
			fclose(handle);
			handle = null;
		}
	}

	//! Is this stream open?
	@property override fn isOpen() bool
	{
		return handle !is null;
	}

	//! Read a single character from this stream.
	override fn get() dchar
	{
		return cast(dchar) fgetc(handle);
	}

	/*!
	 * Read from the stream into buffer.
	 * @return The slice of @p buffer actually used.
	 */
	override fn read(buffer: u8[]) u8[]
	{
		num: size_t = fread(cast(void*)buffer.ptr, 1, buffer.length, handle);
		if (num != buffer.length) {
			return buffer[0..num];
		}
		return buffer;
	}

	//! Has this stream reached EOF?
	override fn eof() bool
	{
		return feof(handle) != 0;
	}
}
