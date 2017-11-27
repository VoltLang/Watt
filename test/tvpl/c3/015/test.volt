//T check:5
//T check:Member
//T check:[1, 2, 3]
module test;

import watt.io;

enum Enum
{
	Member
}

fn main() i32
{
	writeln("${3+2}");
	writeln("${Enum.Member}");
	writeln(new "${[1, 2, 3]}");
	return 0;
}
