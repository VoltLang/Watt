module test;

import watt.text.path;

fn main() i32
{

	assert(concatenatePath("a", "b") == "a/b" || concatenatePath("a", "b") == "a\\b");
	assert(concatenatePath("a/", "b") == "a/b");
	assert(concatenatePath("a/", "/b") == "a/b");
	return 0;
}
