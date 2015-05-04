// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io;

import watt.conv;
import watt.varargs;
import watt.text.format;
import core.stdc.stdio;

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

	void writef(const(char)[] formatString, ref object.TypeInfo[] typeids, ref va_list vl)
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

	void writefln(const(char)[] formatString, ref object.TypeInfo[] typeids, ref va_list vl)
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
		while (c != '\n') {
			buf ~= c;
			c = cast(char) get();
		}
		return cast(string) buf;
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
}

global OutputFileStream output;
global OutputFileStream error;
global InputFileStream input;

global this()
{
	output = new OutputFileStream(null);
	output.handle = stdout;
	error = new OutputFileStream(null);
	error.handle = stderr;
	input = new InputFileStream(null);
	input.handle = stdin;
	return;
}

void write(const(char)[] s)
{
	output.write(s);
}

void writeln(const(char)[] s)
{
	output.writeln(s);
}

void writef(const(char)[] s, ...)
{
	va_list vl;
	va_start(vl);
	output.writef(s, ref _typeids, ref vl);
	va_end(vl);
}

void writefln(const(char)[] s, ...)
{
	va_list vl;
	va_start(vl);
	output.writefln(s, ref _typeids, ref vl);
	va_end(vl);
}

string readln()
{
	return input.readln();
}

