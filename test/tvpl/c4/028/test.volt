//T check:1
//T check:1
module test;

import watt.io;

fn main() i32
{
	a := 0;
	b := ++a;
	writeln(b);
	writeln(a);
	return 0;
}
