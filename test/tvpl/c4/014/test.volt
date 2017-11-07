//T check:you wrote 'banana'
module test;

import watt.io;

fn main() i32
{
	str := "banana";
	if (str == "banana") {
		writeln("you wrote 'banana'");
	} else {
		writeln("you didn't write 'banana'");
	}
	return 0;
}
