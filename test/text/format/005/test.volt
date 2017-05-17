module test;

import core.c.stdio;
import watt.text.format;


fn main() i32
{
	if (format("%s", 5.2f)[0] != '5') {
		return 1;
	}
	printf("%f\n", 5.2f);
	return 0;
}
