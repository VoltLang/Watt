//T compiles:yes
//T retval:42
module test;

import watt.io.seed : getHardwareSeedU32;


int main()
{
	// Testing this more then just making sure it doesn't explode is hard.
	auto foo = getHardwareSeedU32;
	return 42;
}
