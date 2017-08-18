module test;

import watt.conv;

fn main() i32
{
	str := toString(cast(void*)null);
	assert(str.length > 2 && str[0 .. 2] == "00");
	return 0;
}
