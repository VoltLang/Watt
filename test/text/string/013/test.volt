module test;

import watt.io;
import watt.text.string : split;

fn main() i32
{
	arr := split("apple, banana, peach", ", ");
	assert(arr.length == 3);
	assert(arr[0] == "apple");
	assert(arr[1] == "banana");
	assert(arr[2] == "peach");

	arr = split("リンゴ、バナナ、桃", "、");
	assert(arr.length == 3);
	assert(arr[0] == "リンゴ");
	assert(arr[1] == "バナナ");
	assert(arr[2] == "桃");
	
	arr = split("foobar", "の,");
	assert(arr.length == 1);
	assert(arr[0] == "foobar");

	arr = split(", ", ", ");
	assert(arr.length == 2);
	assert(arr[0] == "");
	assert(arr[1] == "");

	return 0;
}
