//T macro:passpath
module test;

import file = watt.io.file;

fn main(args: string[]) i32
{
	file.chdir(args[1]);
	if (file.size("empty.txt") != 0) {
		return 1;
	}
	if (file.size("small.txt") != 3) {
		return 2;
	}
	return 0;
}

