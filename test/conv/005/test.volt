module test;

import watt.conv;

fn main() i32
{
	a: u8 = 0;
	assert(toString(a) == "0");
	b: u8 = 255;
	assert(toString(b) == "255");
	return 0;
}
