//T has-passed:no
module test;

import watt.conv;

fn main() i32
{
	assert(toString(false) == "false");
	assert(toString(true) == "true");
	return 0;
}
