//T check:1
//T check:2
//T check:1
//T check:0
module test;

import watt.io;

fn main() i32
{
	a := 0;
	++a;
	writeln(a);
	a++;
	writeln(a);
	a--;
	writeln(a);
	--a;
	writeln(a);
	return 0;
}
