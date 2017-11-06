//T check:64
module test;

import watt.io;

class IntDoubler
{
	x: i32;
	
	this(x: i32)
	{
		this.x = x * 2;
	}
}

fn main() i32
{
	//id := new IntDoubler();  // Error: expected i32 argument
	id := new IntDoubler(32);
	writeln(id.x);
	return 0;
}
