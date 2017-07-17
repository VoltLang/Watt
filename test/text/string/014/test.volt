module test;

import watt.text.string;

fn main() i32
{
	assert(stripRight(`«   `) == `«`);
	return 0;
}
