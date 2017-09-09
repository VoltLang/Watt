module test;

import watt.math;


fn main() i32
{
	a := -3;
	b := -3.1415926538;
	if (abs(a) != 3 || abs(b) <= 0.0) {
		return 1;
	}
	return 0;
}
