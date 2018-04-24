//T macro:empty
//T run:volta -o %t.returnThree.exe %S/returnThree.volt
//T run:volta -o %t.main %s
//T run:%t.main %t.returnThree.exe
module test;

import watt.process.pipe;

fn main(args: string[]) i32
{
	if (args.length == 1) {
		return 1;
	}
	retval: u32;
	getOutput(args[1], null, ref retval);
	return cast(i32)retval - 3;
}
