module test;

import watt.text.format;


fn main() i32
{
	if (format("%.3f", 3.141592653) != "3.142") {
		return 1;
	}
	return 0;
}
