//T check:true
//T check:true
//T check:true
//T check:false
module test;

import watt.io;

fn main() i32
{
	writefln("%s", true || true);
	writefln("%s", true || false);
	writefln("%s", false || true);
	writefln("%s", false || false);
	return 0;
}
