module test;

import watt.text.string : strip;

extern(C) void printf(const char*, ...);

fn main() i32
{
	string src1 = "  pie  ";
	string src2 = " apple";
	string src3 = "  apple  ";
	string src4 = "apple  ";
	string src5 = "apple  pie   ";

	if (strip(src1).length != 3 ||
	    strip(src2).length != 5 ||
	    strip(src3).length != 5 ||
	    strip(src4).length != 5 ||
	    strip(src5).length != 10) {
		return 1;
	}

	return 0;
}
