//T macro:passpath
module main;

import watt.io.file;

fn main(args: string[]) i32
{
	val := 0;
	fn dgt(path: string) SearchStatus
	{
		val = 17;
		if (path == "stop.txt") {
			val = 1;
			return SearchStatus.Halt;
		}
		return SearchStatus.Continue;
	}
	searchDir(args[1], "*", dgt);
	return val - 1;
}
