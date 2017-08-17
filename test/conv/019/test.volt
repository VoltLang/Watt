module test;

import watt.conv;

fn main() i32
{
	assert(toStringBinary(cast(u8)14) == "00001110");
	return 0;
}
