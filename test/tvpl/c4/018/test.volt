//T check:five is bigger than two
//T check:two is less than five
module test;

import watt.io;

fn main() i32
{
	if (5 > 2) {
		writeln("five is bigger than two");
	}
	if (2 < 5) {
		writeln("two is less than five");
	}
	return 0;
}
