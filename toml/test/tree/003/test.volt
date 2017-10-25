module test;

import toml = watt.toml;

global src := `
"" = "blank"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val[""].str() != "blank") {
		return 1;
	}
	return 0;
}
