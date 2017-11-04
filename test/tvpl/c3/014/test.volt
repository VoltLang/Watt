//T check:A
//T check:hello
module test;

import watt.io;

struct A
{
}

struct B
{
	fn toString() string
	{
		return "hello";
	}
}

fn main() i32
{
	a: A;
	b: B;
	writeln(new "${a}");
	writeln(new "${b}");
	return 0;
}