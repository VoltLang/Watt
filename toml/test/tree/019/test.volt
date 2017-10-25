module test;

import toml = watt.toml;

global src := `
[dog."ta\"ter.m\\an"]
type = "pug"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["dog"][`ta"ter.m\an`]["type"].str() != "pug") {
		return 1;
	}
	return 0;
}
