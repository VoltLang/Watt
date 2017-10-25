module test;

import toml = watt.toml;

global src := `
[ a . b . c ]
b = 42
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["a"]["b"]["c"]["b"].integer() != 42) {
		return 1;
	}
	return 0;
}
