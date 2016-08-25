// Copyright © 2013-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.streams;

import core.typeinfo;
import core.varargs;
import core.stdc.stdio: FILE, fopen, fclose, fputc, fwrite,
                         fflush, feof, fgetc, ungetc, fread;
import watt.conv;
import watt.text.format;
import watt.text.sink : StringSink;

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
	abstract fn close();

	/**
	 * Write a single character out to the sink.
	 */
	abstract fn put(c: dchar);

	/**
	 * Write a series of characters to the sink.
	 */
	fn write(s: const(char)[])
	{
		for (i: size_t = 0u; i < s.length; i = i + 1u) {
			put(s[i]);
		}
	}

	/**
	 * After this call has completed, the state of this stream's
	 * sink should match the data committed to it.
	 */
	abstract fn flush();


	/*
	 *
	 * Format helpers.
	 *
	 */

	/**
	 * Write a series of characters then a newline.
	 */
	fn writeln(s: const(char)[])
	{
		write(s);
		put('\n');
	}

	fn vwritef(formatString: const(char)[], ref typeids: TypeInfo[], ref vl: va_list)
	{
		buf: char[];
		formatImpl(write, formatString, ref typeids, ref vl);
	}


	fn writef(formatString: const(char)[], ...)
	{
		vl: va_list;

		va_start(vl);
		formatImpl(write, formatString, ref _typeids, ref vl);
		va_end(vl);
	}

	fn vwritefln(formatString: const(char)[], ref typeids: TypeInfo[], ref vl: va_list)
	{
		formatImpl(write, formatString, ref typeids, ref vl);
		put('\n');
	}

	fn writefln(formatString: const(char)[], ...)
	{
		vl: va_list;

		va_start(vl);
		formatImpl(write, formatString, ref _typeids, ref vl);
		va_end(vl);
		put('\n');
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
	abstract fn close();

	/**
	 * Returns the character that will be retrieved by get().
	 */
	abstract fn peek() dchar;

	/**
	 * Read a single character from the source.
	 */
	abstract fn get() dchar;

	/**
	 * Read as much data as possible into buffer.
	 * A slice to the input buffer is returned. The returned slice
	 * will be shorter than buffer if EOF was encountered before the
	 * buffer was filled.
	 */
	abstract fn read(buffer: u8[]) u8[];

	/**
	 * Returns true if the stream indicates that there is no more data.
	 * This may never be true, depending on the source.
	 */
	abstract fn eof() bool;


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
	fn readln() string
	{
		buf: StringSink;
		c: char = cast(char) get();
		while (c != '\n' && !eof()) {
			buf.sink([c]);
			c = cast(char) get();
		}
		return buf.toString();
	}
}


/**
 * An OutputStream in which the sink is a file.
 */
class OutputFileStream : OutputStream
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
		fclose(handle);
		handle = null;
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
class InputFileStream : InputStream
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
		fclose(handle);
		handle = null;
	}

	override fn peek() dchar
	{
		c: i32 = fgetc(handle);
		ungetc(c, handle);
		return cast(dchar) c;
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
