module test;

import watt = [watt.io.file, watt.path, watt.text.path, watt.conv];

fn main() i32
{
	auto cptr = watt.toStringz("hello test reader");
	return 0;
}
