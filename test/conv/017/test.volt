//T has-passed:no
module test;

import watt.conv;

fn main() i32
{
	assert(charToString('a') == "a");
	assert(charToString('あ') == "あ");
	return 0;
}
