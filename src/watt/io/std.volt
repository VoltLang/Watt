module watt.io.std;

import core.stdc.stdio : stdout, stderr, stdin;
import watt.io.streams : OutputFileStream, InputFileStream;
import watt.varargs : va_list, va_start, va_end;


global OutputFileStream output;
global OutputFileStream error;
global InputFileStream input;

global this()
{
	output = new OutputFileStream(null);
	error = new OutputFileStream(null);
	input = new InputFileStream(null);
	output.handle = stdout;
	error.handle = stderr;
	input.handle = stdin;
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
	output.vwritef(s, ref _typeids, ref vl);
	va_end(vl);
}

void writefln(const(char)[] s, ...)
{
	va_list vl;
	va_start(vl);
	output.vwritefln(s, ref _typeids, ref vl);
	va_end(vl);
}

string readln()
{
	return input.readln();
}
