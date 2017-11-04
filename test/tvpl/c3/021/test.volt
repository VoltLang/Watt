//T check:Hello there...
//T check:Bob
//T check:Hello there...
//T check:Jenny
module test;

import watt.io;

fn sayHello(name: string)
{
	writeln("Hello there...");
	writeln(name);
}

fn main() i32
{
	sayHello("Bob");
	sayHello("Jenny");
	return 0;
}
