//T compiles:yes
//T retval:0
module test;

import core.c.stdio;
import watt.text.format;

fn main() i32
{
	if (format("% d", 32) != " 32") {
		return 1;
	}
	if (format("% d", -32) != "-32") {
		return 2;
	}
	return 0;
}
