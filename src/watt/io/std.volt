module watt.io.std;

import core.varargs: va_list, va_start, va_end;
import core.stdc.stdio: stdout, stderr, stdin;
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
