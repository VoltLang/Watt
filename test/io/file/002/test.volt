module test;

import watt.io.file : read;

fn main() i32
{
	p := read("..");
	return p !is null ? 4 : 0;
}
