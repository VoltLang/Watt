module test;

import toml = watt.toml;

global src := `
[a.b]
key = "value"
[a]
key = "bar"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["a"]["b"]["key"].str() != "value") {
		return 1;
	}
	if (val["a"]["key"].str() != "bar") {
		return 2;
	}
	return 0;
}
