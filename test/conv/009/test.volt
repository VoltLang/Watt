module test;

import watt.conv;

fn main() i32
{
	a: i8 = cast(i8)-128;
	assert(toString(a) == "-128");
	b: i8 = 0;
	assert(toString(b) == "0");
	c: i8 = 127;
	assert(toString(c) == "127");
	return 0;
}
