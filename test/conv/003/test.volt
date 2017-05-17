module test;

import watt.conv;

fn main() i32
{
	if (toFloat("532.67") > 532.0f && toDouble("1.2") < 2.4) {
		return 0;
	}
	return 12;
}
