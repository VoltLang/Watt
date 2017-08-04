// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Defines standard streams, and some simple utility functions.
module watt.io.std;

version (CRuntime_All || Posix):

import core.varargs: va_list, va_start, va_end;
import watt.io.streams;

//! An `OutputFileStream` that outputs to `stdout`.
global output: OutputFileStream;
//! An `OutputFileStream` that outputs to `stderr`.
global error: OutputFileStream;
//! An `InputFileStream` that reads from `stdin`.
global input: InputFileStream;

/*!
 * Write `s` to `output`.  
 * Same as `output.write(s)`.
 * @Param s An array of characters to be written to `output`.
 */
fn write(s: const(char)[])
{
	output.write(s);
}

/*!
 * Write `s` to `output`, then write a newline character.  
 * Same as `output.writeln(s)`.
 * @Param s An array of characters to be written to `output`, before a newline.
 */
fn writeln(s: const(char)[])
{
	output.writeln(s);
}

/*!
 * Write the string representation of an `i32` to `output`.  
 * Same as `output.writefln("%s", i)`.
 * @Param i An `i32` to write to `output`.
 */
fn writeln(i: i32)
{
	output.writefln("%s", i);
}

/*!
 * Write the string representation of a `bool` to `output`.  
 * Same as `output.writefln("%s", b)`.
 * @Param b A `bool` to write to `output`.
 */
fn writeln(b: bool)
{
	output.writefln("%s", b);
}

/*!
 * Write a newline to `output`.  
 * Same as `output.writeln("")`.
 */
fn writeln()
{
	output.writeln("");
}

/*!
 * Format a string and write it to `output`.  
 * See `watt.text.format` for format string documentation.  
 * Same as `output.writef(s, ...)`.
 * @Param s The format string.
 */
fn writef(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritef(s, ref _typeids, ref vl);
	va_end(vl);
}

/*!
 * Format a string, write it to `output`, then output a newline.  
 * See `watt.text.format` for format string documentation.  
 * Same as `output.writefln(s, ...)`.
 * @Param s The format string.
 */
fn writefln(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritefln(s, ref _typeids, ref vl);
	va_end(vl);
}

/*!
 * Read text from `input`.
 *
 * Blocks until the enter key has been pressed, and the
 * text entered is returned. The newline character is not included
 * in the returned string.
 *
 * Same as `input.readln()`.
 * @Returns The text that was input on `input`, not including the newline.
 */
fn readln() string
{
	return input.readln();
}


private:
version (Posix) {
	import core.c.posix.unistd : STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO;
} else {
	import core.c.stdio : stdout, stderr, stdin;
}

global this()
{
	output = new OutputFileStream(null);
	error = new OutputFileStream(null);
	input = new InputFileStream(null);

	version (Posix) {
		output.fd = STDOUT_FILENO;
		error.fd = STDERR_FILENO;
		input.fd = STDIN_FILENO;
	} else {
		output.handle = stdout;
		error.handle = stderr;
		input.handle = stdin;
	}
}
