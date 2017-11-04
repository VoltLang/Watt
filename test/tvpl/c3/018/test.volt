//T check:but this always will be
module test;

import watt.io;

fn main() i32
{
	a := 10;
	b := 100;
	if (a > b) {
		writeln("a is bigger than b");
	}
	writeln("but this always will be");
	return 0;
}
