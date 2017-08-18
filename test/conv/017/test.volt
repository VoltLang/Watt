module test;

import watt.text.utf;

fn main() i32
{
	assert(encode('a') == "a");
	assert(encode('あ') == "あ");
	return 0;
}
