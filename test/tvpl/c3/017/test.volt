//T check:a is not bigger than b
module test;

import watt.io;

fn main() i32
{
	a := 10;
	b := 100;
	if (a > b) {
		writeln("a is bigger than b");
	} else {
		writeln("a is not bigger than b");
	}
	return 0;
}
