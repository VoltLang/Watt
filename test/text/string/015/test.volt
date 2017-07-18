module test;

import watt.io;
import watt.text.string;

fn main() i32
{
	writefln("%s", split("aaaHELLO", "HELLO"));
	assert(split("aaaHELLO", "HELLO") == ["aaa", ""]);
	return 0;
}
