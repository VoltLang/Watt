//T check:you didn't get it!
module test;

import watt.conv;
import watt.io;

fn main() i32
{
	writeln("I'm thinking of a number between one and one hundred. What is it?");
	n := toInt("320");
	if (n != 32) {
		writeln("you didn't get it!");
	} else {
		writeln("correct!");
	}
	return 0;
}
