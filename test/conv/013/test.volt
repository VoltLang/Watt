module test;

import watt.conv;

fn main() i32
{
	a: f32 = 3.1415926538f;
	astr := toString(a);
	assert(astr[0 .. 5] == "3.141");
	return 0;
}
