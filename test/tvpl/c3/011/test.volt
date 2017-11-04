//T check:January
//T check:December
//T check:March
module test;

import watt.io;

fn main() i32
{
	months := ["January", "February", "March", "April", "May",
		"June", "July", "August", "September", "October", "November", "December"];
	writeln(months[0]);
	writeln(months[11]);
	writeln(months[1+1]);
	return 0;
}