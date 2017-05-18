module test;

import watt.text.format;

fn main() i32
{
	dchar c = 'の';
	return format("%s", c) == "の" ? 0 : 1;
}
