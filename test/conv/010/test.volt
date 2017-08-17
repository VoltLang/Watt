module test;

import watt.conv;

fn main() i32
{
	a: i16 = cast(i16)-32768;
	assert(toString(a) == "-32768");
	b: i16 = 0;
	assert(toString(b) == "0");
	c: i16 = 32767;
	assert(toString(c) == "32767");
	return 0;
}
