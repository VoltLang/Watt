module test;

import watt.text.string;

fn main() i32
{
	return cast(int)indexOf(["aa", "bb", "cc"], "bb") - 1;
}
