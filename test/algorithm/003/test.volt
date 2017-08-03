module test;

import watt.algorithm;

i32 main()
{
	a := [3, 2, 5, 0, -3, 2];
	sort(a);
	return a[$-1] + a[0] - 2;
}
