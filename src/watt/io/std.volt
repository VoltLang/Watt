// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Functions to handle input and output to standard streams.
 */
module watt.io.std;

version (CRuntime_All || Posix):

import core.varargs: va_list, va_start, va_end;
import watt.io.streams;

/*!
 * An @p OutputFileStream that outputs to @p stdout.
 */
global output: OutputFileStream;
/*!
 * An @p OutputFileStream that outputs to @p stderr.
 */
global error: OutputFileStream;
/*!
 * An @p InputFileStream that reads from @p stdin.
 */
global input: InputFileStream;

/*!
 * Write @p s to @p output. Same as output.writeln.
 * @param[in] s An array of characters to be written to output.
 */
fn write(s: const(char)[])
{
	output.write(s);
}

/*!
 * Write @p s to @p output, then write a newline character to @p output.
 * Same as output.writeln.
 * @param[in] s An array of characters to be written to @p output, before a newline.
 */
fn writeln(s: const(char)[])
{
	output.writeln(s);
}

/*!
 * Write the string representation of an @p i32 to @p output.
 * Same as output.writefln("%s", i).
 * @param[in] i An @p i32 to write to @p output.
 */
fn writeln(i: i32)
{
	output.writefln("%s", i);
}

/*!
 * Write the string representation of a @p bool to @p output.
 * Same as output.writefln("%s", b).
 * @param[in] b A @p bool to write to @p output.
 */
fn writeln(b: bool)
{
	output.writefln("%s", b);
}

/*!
 * Write a newline to @output.
 * Same as output.writeln("").
 */
fn writeln()
{
	output.writeln("");
}

/*!
 * Format a string and write it to @p output.
 * See @p watt.text.format for format string documentation.
 * Same as output.writef(s, ...).
 * @param[in] s The format string.
 */
fn writef(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritef(s, ref _typeids, ref vl);
	va_end(vl);
}

/*!
 * Format a string, write it to @p output, then output a newline.
 * See @p watt.text.format for format string documentation.
 * Same as output.writefln(s, ...).
 * @param[in] s The format string.
 */
fn writefln(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritefln(s, ref _typeids, ref vl);
	va_end(vl);
}

/*!
 * Read text from @p input.
 * @p readln blocks until the enter key has been pressed, and the
 * text entered is returned. The newline character is not included
 * in the returned string.
 * Same as input.readln().
 * @return The text that was input on @p input, not including the newline.
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
