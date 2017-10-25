module test;

import toml = watt.toml;

global src := `
[a.b.c]
key = "value"
[foo]
key = "bar"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["a"]["b"]["c"]["key"].str() != "value") {
		return 1;
	}
	if (val["foo"]["key"].str() != "bar") {
		return 2;
	}
	return 0;
}
