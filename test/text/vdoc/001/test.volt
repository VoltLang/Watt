module test;

import watt.text.vdoc;

fn main() i32
{
	tests := [
		["*!\r\n * Add two numbers together.\r\n */", "Add two numbers together."],
		["/! This is a brief. This is not.\r", "This is a brief."]
	];
	foreach (test; tests) {
		assert(rawToBrief(test[0]) == test[1]);
	}
	return 0;
}
