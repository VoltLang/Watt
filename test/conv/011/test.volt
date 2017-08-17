module test;

import watt.conv;

fn main() i32
{
	a: i32 = -2147483648;
	assert(toString(a) == "-2147483648");
	b: i32 = 0;
	assert(toString(b) == "0");
	c: i32 = 2147483647;
	assert(toString(c) == "2147483647");
	return 0;
}
