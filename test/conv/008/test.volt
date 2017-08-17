module test;

import watt.conv;

fn main() i32
{
	a: u64 = 0;
	assert(toString(a) == "0");
	b: u64 = 18446744073709551615UL;
	assert(toString(b) == "18446744073709551615");
	return 0;
}
