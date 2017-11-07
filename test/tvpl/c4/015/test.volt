//T check:you didn't write 'banana'
module test;

import watt.io;

fn main() i32
{
	str := "not banana";
	if (str == "banana") {
		writeln("you wrote 'banana'");
	} else {
		writeln("you didn't write 'banana'");
	}
	return 0;
}
