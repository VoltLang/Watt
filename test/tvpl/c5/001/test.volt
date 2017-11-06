//T check:2
//T check:hello
module test;

import watt.io;

fn main() i32
{
	{
		x := 2;
		writeln(x);
	}
	{
		x := "hello";
		writeln(x);
	}
	return 0;
}
