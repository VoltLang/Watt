module test;

import toml = watt.toml;

global src := `
[dog.'tater.man']
type = "pug"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["dog"]["tater.man"]["type"].str() != "pug") {
		return 1;
	}
	return 0;
}
