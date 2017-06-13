module test;

import watt.math;

fn main() i32
{
	return cast(i32)round(4.4) - cast(i32)round(4.6f) + 1;
}

