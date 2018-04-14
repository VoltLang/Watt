// Copyright 2013-2017, Bernard Helyer.
// Copyright 2016-2017, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Standard streams and simple utility functions.
 *
 * The global declaration of the @ref watt.io.streams that map
 * onto the operating system's standard output, input, and error.
 *
 * There are also some simple functions declared here. These are
 * the default `writeln` and friends you use when you import
 * `watt.io`. The writing functions output to standard output,
 * and the reading functions read from standard input.
 *
 * ### Example
 * ```volt
 * // This:
 * writeln("Hello, world.");
 * // ...is equivalent to this:
 * output.writeln("Hello, world.");
 * ```
 */
module watt.io.std;

version (CRuntime_All || Posix):

import core.varargs: va_list, va_start, va_end;
import watt.io.streams;

/*!
 * An @ref watt.io.streams.OutputFileStream that outputs to `stdout`.
 *
 * This will appear on the console/terminal, if the
 * application was launched from one.
 */
global output: OutputFileStream;

/*!
 * An @ref watt.io.streams.OutputFileStream that outputs to `stderr`.
 *
 * Like @ref watt.io.std.output, this will appear on the console,
 * but is used for errors, and can be redirected separately to output.
 */
global error: OutputFileStream;

/*!
 * An @ref watt.io.streams.InputFileStream that reads from `stdin`.
 *
 * This will either read from the user's keyboard, or from a file redirected
 * to `stdin` by the user.
 */
global input: InputFileStream;

/*!
 * Write `s` to `output`.
 *
 * Same as `output.write(s)`.
 * @Param s An array of characters to be written to `output`.
 */
fn write(s: const(char)[])
{
	output.write(s);
}

/*!
 * Write `s` to `output`, then write a newline character.
 *
 * Same as `output.writeln(s)`.
 * @Param s An array of characters to be written to `output`, before a newline.
 */
fn writeln(s: const(char)[])
{
	output.writeln(s);
}

/*!
 * Write the string representation of an `i32` to `output`.
 *
 * Same as `output.writefln("%s", i)`.
 * @Param i An `i32` to write to `output`.
 */
fn writeln(i: i32)
{
	output.writefln("%s", i);
}

/*!
 * Write the string representation of a `size_t` to `output`.
 *
 * Same as `output.writefln("%s", i)`.
 * @Param i A `size_t` to write to `output`.
 */
fn writeln(i: size_t)
{
	output.writefln("%s", i);
} 

/*!
 * Write the string representation of a `bool` to `output`.
 *
 * Same as `output.writefln("%s", b)`.
 * @Param b A `bool` to write to `output`.
 */
fn writeln(b: bool)
{
	output.writefln("%s", b);
}

/*!
 * Write a newline to `output`.
 *
 * Same as `output.writeln("")`.
 */
fn writeln()
{
	output.writeln("");
}

/*!
 * Format a string and write it to `output`.
 *
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
 *
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

global ~this()
{
	output.flush();
	error.flush();
}
