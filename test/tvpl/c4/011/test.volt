//T macro:expect-failure
//T check:escape
module test;

import watt.io;

global integers: scope i32*[];

fn storeInteger(ip: scope i32*) scope i32*
{
	return ip;
}

fn processIntegers()
{
	foreach (ip; integers) {
		*ip = *ip * 2;
		writeln(*ip);  // output ????
	}
}

fn apiUser()
{
	i := 32;
	storeInteger(&i);
}

fn main() i32
{
	apiUser();
	processIntegers();
	return 0;
}
