//T check:true
//T check:true
//T check:false
//T check:true
//T check:true
//T check:false
module test;

import watt.io;

fn main() i32
{
	writefln("%s", 5 >= 4);
	writefln("%s", 5 >= 5);
	writefln("%s", 5 >= 6);
	writefln("%s", 4 <= 5);
	writefln("%s", 4 <= 4);
	writefln("%s", 4 <= 3);
	return 0;
}
