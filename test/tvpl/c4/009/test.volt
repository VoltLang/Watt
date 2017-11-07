//T check:64
module test;

import watt.io;

fn processInteger(ip: i32*)
{
	*ip = *ip * 2;
}

fn apiUser()
{
	i := 32;
	processInteger(&i);
	writeln(i);  // output '64'
}

fn main() i32
{
	apiUser();
	return 0;
}
