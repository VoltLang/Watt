module test;

import watt.conv;

fn main() i32
{
	a: u32 = 0;
	assert(toString(a) == "0");
	b: u32 = 4294967295U;
	assert(toString(b) == "4294967295");
	return 0;
}
