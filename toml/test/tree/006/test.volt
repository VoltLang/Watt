module test;

import toml = watt.toml;

global src := `
key = "value1"
[table]
key = "value2"
[table2]
key = "value3"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["key"].str() != "value1") {
		return 1;
	}
	if (val["table"]["key"].str() != "value2") {
		return 2;
	}
	if (val["table2"]["key"].str() != "value3") {
		return 3;
	}
	return 0;
}
