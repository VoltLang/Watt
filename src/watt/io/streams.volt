// Copyright © 2013-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.streams;

import core.stdc.stdio : FILE, fopen, fclose, fputc, fwrite,
                         fflush, feof, fgetc, ungetc, fread;
import watt.conv;
import watt.varargs;
import watt.text.format;

/**
 * OutputStreams write data to some sink (a file, a console, etc)
 * in characters.
 */
class OutputStream
{
public:
	this()
	{
		return;
	}

	/**
	 * Close the stream.
	 */
	void close()
	{
		return;
	}

	/**
	 * Write a single character out to the sink.
	 */
	void put(dchar c)
	{
		return;
	}

	/**
	 * Write a series of characters to the sink.
	 */
	void write(const(char)[] s)
	{
		for (size_t i = 0u; i < s.length; i = i + 1u) {
			put(s[i]);
		}
		return;
	}

	/**
	 * Write a series of characters then a newline.
	 */
	void writeln(const(char)[] s)
	{
		write(s);
		put('\n');
		return;
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
		return;
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
		return;
	}

	/**
	 * After this call has completed, the state of this stream's
	 * sink should match the data committed to it.
	 */
	void flush()
	{
		return;
	}
}

/**
 * InputStreams read data from some source (a file, a device, etc)
 */
class InputStream
{
public:
	this()
	{
		return;
	}

	/**
	 * Close the input stream.
	 */
	void close()
	{
		return;
	}

	/**
	 * Returns the character that will be retrieved by get().
	 */
	dchar peek()
	{
		return cast(dchar) -1;
	}

	/**
	 * Read a single character from the source.
	 */
	dchar get()
	{
		return cast(dchar) -1;
	}

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

	/**
	 * Read as much data as possible into buffer.
	 * A slice to the input buffer is returned. The returned slice
	 * will be shorter than buffer if EOF was encountered before the
	 * buffer was filled.
	 */
	ubyte[] read(ubyte[] buffer)
	{
		return buffer[0..0];
	}

	/**
	 * Returns true if the stream indicates that there is no more data.
	 * This may never be true, depending on the source.
	 */
	bool eof()
	{
		return true;
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
		return;
	}

	override void close()
	{
		fclose(handle);
		handle = null;
		return;
	}

	override void write(const(char)[] s)
	{
		fwrite(s.ptr, 1, s.length, handle);
	}

	override void put(dchar c)
	{
		fputc(cast(int) c, handle);
		return;
	}

	override void flush()
	{
		fflush(handle);
		return;
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
		return;
	}

	override void close()
	{
		fclose(handle);
		handle = null;
		return;
	}

	override bool eof()
	{
		return feof(handle) != 0;
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
		size_t num = fread(buffer.ptr, 1, buffer.length, handle);
		if (num != buffer.length) {
			return buffer[0..num];
		}
		return buffer;
	}
}

