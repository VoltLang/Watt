// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.std;

version (CRuntime_All):

import core.varargs: va_list, va_start, va_end;
import core.c.stdio: stdout, stderr, stdin;
import watt.io.streams: OutputFileStream, InputFileStream;


global output: OutputFileStream;
global error: OutputFileStream;
global input: InputFileStream;

global this()
{
	output = new OutputFileStream(null);
	error = new OutputFileStream(null);
	input = new InputFileStream(null);
	output.handle = stdout;
	error.handle = stderr;
	input.handle = stdin;
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
