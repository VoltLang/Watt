module test;

import toml = watt.toml;

global src := `
lang = "日本語"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["lang"].str() != "日本語") {
		return 1;
	}
	return 0;
}
