module test;

import conv = watt.conv;

fn main() i32
{
	aa: bool[string];
	foreach (i; 0 .. 1000) {
		aa[conv.toString(i)] = true;
	}
	if (aa.length != 1000) {
		return 1;
	}
	foreach (k, v; aa) {
		aa.remove(k);
	}
	return cast(i32)aa.length;
}
