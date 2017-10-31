
module test;

import core.c.stdlib;
import core.exception;
import core.rt.eh;
import toml = watt.toml;

enum TOMLFILE = `
a = [
	"af"
	"b"
]
`;

fn onThrow(t: Throwable, location: string)
{
	if (e := cast(toml.TomlException)t) {
		exit(0);
	} else {
		exit(1);
	}
}

fn main() i32
{
	vrt_eh_set_callback(onThrow);
	root := toml.parse(TOMLFILE);
	return 2;
}
