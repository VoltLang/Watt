// Copyright © 2013-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Define an IO stream interface. (Interfaces for reading and writing to things, one character at a time.)
module watt.io.streams;

import core.typeinfo;
import core.varargs;
import watt.conv;
import watt.text.format;
import watt.text.sink : StringSink;

// Make sure these imports doesn't specifiy imports.
public import watt.io.streams.fd;
public import watt.io.streams.stdc;


version (Posix) {
	alias InputFileStream = InputFDStream;
	alias OutputFileStream = OutputFDStream;
} else version (CRuntime_All) {
	alias InputFileStream = InputStdcStream;
	alias OutputFileStream = OutputStdcStream;
}

/*!
 * OutputStreams write data to some sink (a file, a console, etc)
 * in characters.
 */
abstract class OutputStream
{
public:
	/*!
	 * Close the stream.
	 */
	abstract fn close();

	/*!
	 * Returns true if the stream is open.
	 */
	@property abstract fn isOpen() bool;

	/*!
	 * Write a single character out to the sink.
	 */
	abstract fn put(c: dchar);

	/*!
	 * Write a series of characters to the sink.
	 */
	fn write(s: scope const(char)[])
	{
		for (i: size_t = 0u; i < s.length; i = i + 1u) {
			put(s[i]);
		}
	}

	/*!
	 * After this call has completed, the state of this stream's
	 * sink should match the data committed to it.
	 */
	abstract fn flush();


	/*
	 *
	 * Format helpers.
	 *
	 */

	/*!
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


	/*!
	 * Write a formatted string.
	 * See @p watt.text.format for format string details.
	 */
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

	/*!
	 * Write a formatted string and then a newline.
	 * See @p watt.text.format for format string details.
	 */
	fn writefln(formatString: const(char)[], ...)
	{
		vl: va_list;

		va_start(vl);
		formatImpl(write, formatString, ref _typeids, ref vl);
		va_end(vl);
		put('\n');
	}
}

/*!
 * InputStreams read data from some source (a file, a device, etc)
 */
abstract class InputStream
{
public:
	/*!
	 * Close the input stream.
	 */
	abstract fn close();

	/*!
	 * Returns true if the stream is open.
	 */
	@property abstract fn isOpen() bool;

	/*!
	 * Read a single character from the source.
	 */
	abstract fn get() dchar;

	/*!
	 * Read as much data as possible into buffer.
	 * A slice to the input buffer is returned. The returned slice
	 * will be shorter than buffer if EOF was encountered before the
	 * buffer was filled.
	 */
	abstract fn read(buffer: u8[]) u8[];

	/*!
	 * Returns true if the stream indicates that there is no more data.
	 * This may never be true, depending on the source.
	 */
	abstract fn eof() bool;


	/*
	 *
	 * Helpers.
	 *
	 */

	/*!
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
