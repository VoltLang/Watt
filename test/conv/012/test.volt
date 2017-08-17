//T has-passed:no
module test;

import watt.conv;

fn main() i32
{
	a: i64 = -9223372036854775808L;
	assert(toString(a) == "-9223372036854775808");
	assert(toString(i64.min) == "-9223372036854775808");
	b: i64 = 0;
	assert(toString(b) == "0");
	c: i64 = 9223372036854775807L;
	assert(toString(c) == "9223372036854775807");
	return 0;
}
