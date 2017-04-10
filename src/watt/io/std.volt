// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.std;

version (CRuntime_All || Posix):

import core.varargs: va_list, va_start, va_end;

version (Posix) {
	import core.c.posix.unistd : STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO;
	import watt.io.streams.fd : OutputFDStream, InputFDStream;

	global output: OutputFDStream;
	global error: OutputFDStream;
	global input: InputFDStream;

} else {
	import watt.io.streams.stdc : OutputStdcStream, InputStdcStream;
	import core.c.stdio: stdout, stderr, stdin;

	global output: OutputStdcStream;
	global error: OutputStdcStream;
	global input: InputStdcStream;
}

global this()
{
	version (Posix) {
		output = new OutputFDStream(null);
		error = new OutputFDStream(null);
		input = new InputFDStream(null);
		output.fd = STDOUT_FILENO;
		error.fd = STDERR_FILENO;
		input.fd = STDIN_FILENO;
	} else {
		output = new OutputStdcStream(null);
		error = new OutputStdcStream(null);
		input = new InputStdcStream(null);
		output.handle = stdout;
		error.handle = stderr;
		input.handle = stdin;
	}
}

global ~this()
{
	if (output !is null) { output.flush(); }
	if (error !is null) { error.flush(); }
}

fn write(s: const(char)[])
{
	output.write(s);
}

fn writeln(s: const(char)[])
{
	output.writeln(s);
}

fn writeln(i: i32)
{
	output.writefln("%s", i);
}

fn writeln(b: bool)
{
	output.writefln("%s", b);
}

fn writeln()
{
	output.writeln("");
}

fn writef(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritef(s, ref _typeids, ref vl);
	va_end(vl);
}

fn writefln(s: const(char)[], ...)
{
	vl: va_list;
	va_start(vl);
	output.vwritefln(s, ref _typeids, ref vl);
	va_end(vl);
}

fn readln() string
{
	return input.readln();
}
