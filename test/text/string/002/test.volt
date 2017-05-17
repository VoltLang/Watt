module test;

import watt.text.string;

fn main() i32
{
	if (splitLines("a\nb\rc\r\nd") != ["a", "b", "c", "d"]) {
		return 4;
	}
	if (splitLines("") != null) {
		return 1;
	}
	return 0;
}
