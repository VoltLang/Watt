module test;

import watt.conv;

fn main() i32
{
	a: u16 = 0;
	assert(toString(a) == "0");
	b: u16 = 65535;
	assert(toString(b) == "65535");
	return 0;
}
