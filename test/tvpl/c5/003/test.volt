//T check:0
//T check:1
//T check:2
module test;

import watt.io;

fn main() i32
{
	i := 0;
	while (i < 3) {
		writeln(i++);
	}
	return 0;
}
