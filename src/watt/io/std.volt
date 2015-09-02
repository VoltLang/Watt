module watt.io.std;

import core.stdc.stdio : stdout, stderr, stdin;
import watt.io.streams : OutputFileStream, InputFileStream;
import watt.varargs : va_list, va_start, va_end;


global OutputFileStream output;
global OutputFileStream error;
global InputFileStream input;

global this()
{
	version (MSVC) {
		object.vrt_gc_init();
		object.allocDg = object.vrt_gc_get_alloc_dg();
	}

	output = new OutputFileStream(null);
	output.handle = stdout;
	error = new OutputFileStream(null);
	error.handle = stderr;
	input = new InputFileStream(null);
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
