module test;

import watt.io;
import watt.text.string;

fn main() i32
{
	if (stripLeft("    apple ") != "apple " ||
	    stripLeft(" \n\t ") != "" ||
	    stripLeft("") != "") {
		return 4;
	}
	if (strip("  banana  ") != "banana" ||
	    strip(" \n\t ") != "" ||
	    strip("") != "") {
		return 1;
	}

	if (stripRight(" eggplant    ") != " eggplant" ||
	    stripRight(" \n\t ") != "" ||
	    stripRight("") != "") {
		return 2;
	}
	return 0;
}
