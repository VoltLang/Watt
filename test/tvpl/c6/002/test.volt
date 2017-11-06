//T check:1
module test;

import watt.io;

fn callDg(dgt: scope dg())
{
	dgt();
}

fn main() i32
{
	i := 0;
	fn addOneToI()
	{
		i++;
	}
	callDg(addOneToI);
	writeln(i);
	return 0;
}
