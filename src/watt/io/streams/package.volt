// Copyright 2013-2017, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Stream interfaces for input and output.
 *
 * A stream is an interface that reads or
 * writes to a destination, one character at a time.
 *
 * Watt ships with implementations of `OutputFileStream` and `InputFileStream`
 * appropriate for the current platform.
 *
 * Use the plain `OutputStream` and `InputStream` definition where possible,
 * and then the implementation is not important.
 * ### Example
 * ```volt
 * fn outputAnImportantThing(os: OutputStream)
 * ...
 * outputAnImportantThing(output);
 * outputAnImportantThing(new OutputFileStream("foo.txt"));
 * ```
 */
module watt.io.streams;

import core.typeinfo;
import core.varargs;
import watt.conv;
import watt.text.format;
import watt.text.sink : StringSink;

// Make sure these imports don't specifically import symbols.
public import watt.io.streams.fd;
public import watt.io.streams.stdc;


version (Posix) {
	//! An implementation of the `InputStream` for files.
	alias InputFileStream = InputFDStream;
	//! An implementation of the `OutputStream` for files.
	alias OutputFileStream = OutputFDStream;
} else version (CRuntime_All) {
	//! An implementation of the `InputStream` for files.
	alias InputFileStream = InputStdcStream;
	//! An implementation of the `OutputStream` for files.
	alias OutputFileStream = OutputStdcStream;
}

/*!
 * `OutputStream`s write data to a destination (file, console, etc)
 * in characters.
 */
abstract class OutputStream
{
public:
	/*!
	 * Close the stream.
	 *
	 * This calls @ref watt.io.streams.OutputStream.flush,
	 * so there is no need to do it before closing:
	 * ```volt
	 * ofs.put('A');
	 * ofs.flush();  // Unneeded!
	 * ofs.close();
	 * ```
	 */
	abstract fn close();

	/*!
	 * Determine the stream state.
	 *
	 * If an `OutputStream` is 'open', it is connected to a valid destination,
	 * and is ready to write input.
	 * @Returns `true` if this stream is open.
	 */
	@property abstract fn isOpen() bool;

	/*!
	 * Write a single character out to the sink.
	 *
	 * This interface does not guarantee that writes will happen immediately,
	 * but they will happen in order. Call @ref watt.io.streams.OutputStream.flush
	 * if you need to ensure that pending output has been written.
	 */
	abstract fn put(c: dchar);

	/*!
	 * Write a series of characters to the sink.
	 *
	 * This is the same as calling @ref watt.io.streams.OutputStream.put in a loop.
	 */
	fn write(s: scope const(char)[])
	{
		for (i: size_t = 0u; i < s.length; i = i + 1u) {
			put(s[i]);
		}
	}

	/*!
	 * Ensure that all pending writes (from the @ref watt.io.streams.OutputStream.put
	 * and @ref watt.io.streams.OutputStream.write functions) are completed.
	 *
	 * This call will block until all pending writes are completed.
	 */
	abstract fn flush();


	/*
	 * Format helpers.
	 */

	/*!
	 * Write a series of characters then a newline.
	 *
	 * This is the same as calling @ref watt.io.streams.OutputStream.write, then @ref watt.io.streams.OutputStream.put with `'\n'`.
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
	 *
	 * See @ref watt.text.format.format for format string details.
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
	 *
	 * See @ref watt.text.format.format for format string details.  
	 * This is the same as calling @ref watt.io.streams.OutputStream.writef, then @ref watt.io.streams.OutputStream.put.
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
 * `InputStream`s read data in characters from a source (file, device, etc).
 */
abstract class InputStream
{
public:
	/*!
	 * Close this stream.
	 *
	 * A closed stream will read no more data.
	 */
	abstract fn close();

	/*!
	 * Determine this stream's state.
	 *
	 * An `InputStream` is open if it has a valid connection to the source.
	 * @Returns `true` if this stream is open.
	 */
	@property abstract fn isOpen() bool;

	/*!
	 * Read a single character from the source.
	 *
	 * @Returns The character that was read.
	 */
	abstract fn get() dchar;

	/*!
	 * Read as much data as possible into buffer.
	 *
	 * This function does not allocate additional memory into `buffer`;
	 * if a zero length array is given to `buffer`, no data will be read.
	 * @Returns A slice into the input buffer. This slice could be shorter
	 * than the input buffer if an EOF was encountered before it could be filled.
	 */
	abstract fn read(buffer: u8[]) u8[];

	/*!
	 * Is the source out of data?
	 *
	 * This may never be `true`, depending on the source.
	 * @Returns `true` if there is no more data to read.
	 */
	abstract fn eof() bool;


	/*
	 * Helpers.
	 */

	/*!
	 * Read input until a newline character is encountered.
	 *
	 * The newline is not included in the returned data, and the
	 * newline that terminated this function will not be read by
	 * further calls to @ref watt.io.streams.InputStream.get.
	 * @Returns The data that was read, not including the newline.
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
