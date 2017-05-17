module test;

import watt.conv;

fn main(args: string[]) i32
{
	if (9223372036854775887UL != toUlong("9223372036854775887")) {
		return 1;
	}
	return 0;
}

