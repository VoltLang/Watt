//T check:hi!
//T check:bye!
module test;

import watt.io;

fn main() i32
{
	scope (exit) {
		writeln("bye!");
	}
	writeln("hi!");
	return 0;
}
