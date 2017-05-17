module test;

import watt.io.seed : getHardwareSeedU32;


fn main() i32
{
	// Testing this more then just making sure it doesn't explode is hard.
	foo := getHardwareSeedU32;
	return 0;
}
