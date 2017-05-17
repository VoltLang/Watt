module test;

import watt.text.string;

fn main() i32
{
	return cast(int)count("aabc", 'a') + cast(int)count("", 'd') - 2;
}
