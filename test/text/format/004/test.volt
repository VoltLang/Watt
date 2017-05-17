module test;

import watt.text.format;

fn main() i32
{
	if (format("% 4s", 12) != "  12") {
		return 1;
	}
	if (format("% 4s", 1234) != " 1234") {
		return 2;
	}
	if (format("% 4s", -12) != " -12") {
		return 3;
	}
	if (format("% 4s", -1234) != "-1234") {
		return 4;
	}
	return 0;
}
