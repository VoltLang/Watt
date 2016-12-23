//T compiles:yes
//T retval:0
module test;

import watt.io;

fn main() i32
{
	writeln(cast(u8)42);
	return 0;
}
