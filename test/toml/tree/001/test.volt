module test;

import io = watt.io;
import file = watt.io.file;
import toml = watt.toml;

global src := `
hello = "world"
zero = 0
two = 2
foo = false
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["hello"].str() != "world" ||
		(val["zero"].integer() + val["two"].integer()) != 2 ||
		val["foo"].boolean()) {
		return 1;
	}
	return 0;
}
