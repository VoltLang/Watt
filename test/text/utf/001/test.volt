module test;

import watt.text.utf;

fn main() i32
{
	string s = "こんにちは";
	size_t index;
	if (decode(s, ref index) == 'こ') {
		if (decode(s, ref index) == 'ん') {
			return 0;
		}
	}
	return 1;
}
