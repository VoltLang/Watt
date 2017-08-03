module test;

import watt.algorithm;

struct I32Sorter = mixin Sorter!i32;

i32 main()
{
	a := [3, 2, 5, 0, -3, 2];
	I32Sorter.sort(a);
	return a[$-1] + a[0] - 2;
}
