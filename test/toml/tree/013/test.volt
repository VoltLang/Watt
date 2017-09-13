module test;

import core.c.stdlib;
import core.exception;
import core.rt.eh;

import toml = watt.toml;

fn onThrow(t: Throwable, location: string)
{
	if (e := cast(toml.TomlException)t) {
		exit(0);
	} else {
		exit(1);
	}
}

global src := `
[]
key = 1
`;

fn main(args: string[]) i32
{
	vrt_eh_set_callback(onThrow);
	val := toml.parse(src);
	return 2;
}
