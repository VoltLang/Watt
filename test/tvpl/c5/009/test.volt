//T check:10
module test;

import watt.io;

fn main() i32
{
	i := 0;
	while (i < 10) {
		if (++i <= 9) {
			continue;
		}
		writeln(i);
	}
	return 0;
}
