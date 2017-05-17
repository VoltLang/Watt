module test;

import watt.io.std : output;

fn foo(s:string)
{
	output.writeln(s);
}

fn main() i32
{
	const(char)[] s = "Hello, world.";
	foo(s);
	return 0;
}

