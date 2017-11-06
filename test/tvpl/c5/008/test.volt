//T check:three
module test;

import watt.io;

fn main() i32
{
	a := 3;
	switch (a) {
	case 1, 2:
		writeln("one or two");
		break;
	case 3:
		writeln("three");
		break;
	default:
		writeln("default");
		break;
	}
	return  0;
}
