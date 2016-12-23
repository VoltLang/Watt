//T compiles:yes
//T retval:7
module test;

import watt.io;
import watt.text.string;

int main()
{
	writefln("uh");
	if (stripLeft("    apple ") != "apple " ||
	    stripLeft(" \n\t ") != "" ||
	    stripLeft("") != "") {
		return 0;
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
	return 7;
}
