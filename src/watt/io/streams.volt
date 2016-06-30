// Copyright © 2013-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.streams;

static import object;

import core.stdc.stdio : FILE, fopen, fclose, fputc, fwrite,
                         fflush, feof, fgetc, ungetc, fread;
import watt.conv;
import watt.varargs;
import watt.text.format;

/**
 * OutputStreams write data to some sink (a file, a console, etc)
 * in characters.
 */
abstract class OutputStream
{
public:
	/**
	 * Close the stream.
	 */
	abstract void close();

	/**
	 * Write a single character out to the sink.
	 */
	abstract void put(dchar c);

	/**
	 * Write a series of characters to the sink.
	 */
	void write(const(char)[] s)
	{
		for (size_t i = 0u; i < s.length; i = i + 1u) {
			put(s[i]);
		}
	}

	/**
	 * After this call has completed, the state of this stream's
	 * sink should match the data committed to it.
	 */
	abstract void flush();


	/*
	 *
	 * Format helpers.
	 *
	 */

	/**
	 * Write a series of characters then a newline.
	 */
	void writeln(const(char)[] s)
	{
		write(s);
		put('\n');
	}

	void vwritef(const(char)[] formatString, ref object.TypeInfo[] typeids, ref va_list vl)
	{
		char[] buf;
		formatImpl(formatString, ref typeids, ref buf, ref vl);
		write(buf);
	}


	void writef(const(char)[] formatString, ...)
	{
		char[] buf;
		va_list vl;

		va_start(vl);
		formatImpl(formatString, ref _typeids, ref buf, ref vl);
		va_end(vl);
		write(buf);
	}

	void vwritefln(const(char)[] formatString, ref object.TypeInfo[] typeids, ref va_list vl)
	{
		char[] buf;
		formatImpl(formatString, ref typeids, ref buf, ref vl);
		writeln(buf);
	}

	void writefln(const(char)[] formatString, ...)
	{
		char[] buf;
		va_list vl;

		va_start(vl);
		formatImpl(formatString, ref _typeids, ref buf, ref vl);
		va_end(vl);
		writeln(buf);
	}
}

/**
 * InputStreams read data from some source (a file, a device, etc)
 */
abstract class InputStream
{
public:
	/**
	 * Close the input stream.
	 */
	abstract void close();

	/**
	 * Returns the character that will be retrieved by get().
	 */
	abstract dchar peek();

	/**
	 * Read a single character from the source.
	 */
	abstract dchar get();

	/**
	 * Read as much data as possible into buffer.
	 * A slice to the input buffer is returned. The returned slice
	 * will be shorter than buffer if EOF was encountered before the
	 * buffer was filled.
	 */
	abstract ubyte[] read(ubyte[] buffer);

	/**
	 * Returns true if the stream indicates that there is no more data.
	 * This may never be true, depending on the source.
	 */
	abstract bool eof();


	/*
	 *
	 * Helpers.
	 *
	 */

	/**
	 * Read input until a newline character is encountered.
	 *
	 * The newline is discarded.
	 */
	string readln()
	{
		char[] buf;
		char c = cast(char) get();
		while (c != '\n' && !eof()) {
			buf ~= c;
			c = cast(char) get();
		}
		return cast(string) buf;
	}
}


/**
 * An OutputStream in which the sink is a file.
 */
class OutputFileStream : OutputStream
{
public:
	FILE* handle;

public:
	this(const(char)[] filename)
	{
		if (filename.length > 0u) {
			handle = fopen(filename.ptr, "w".ptr);
		}
	}

	override void close()
	{
		fclose(handle);
		handle = null;
	}

	override void put(dchar c)
	{
		fputc(cast(int) c, handle);
	}

	override void write(const(char)[] s)
	{
		fwrite(cast(void*)s.ptr, 1, s.length, handle);
	}

	override void flush()
	{
		fflush(handle);
	}
}

/**
 * An InputStream in which the source is a file.
 */
class InputFileStream : InputStream
{
public:
	FILE* handle;

public:
	this(const(char)[] filename)
	{
		if (filename.length > 0u) {
			handle = fopen(filename.ptr, "r".ptr);
		}
	}

	override void close()
	{
		fclose(handle);
		handle = null;
	}

	override dchar peek()
	{
		int c = fgetc(handle);
		ungetc(c, handle);
		return cast(dchar) c;
	}

	override dchar get()
	{
		return cast(dchar) fgetc(handle);
	}

	override ubyte[] read(ubyte[] buffer)
	{
		size_t num = fread(cast(void*)buffer.ptr, 1, buffer.length, handle);
		if (num != buffer.length) {
			return buffer[0..num];
		}
		return buffer;
	}

	override bool eof()
	{
		return feof(handle) != 0;
	}
}
