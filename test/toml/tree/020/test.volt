module test;

import toml = watt.toml;

global src := `
[a."nes\"\\ted".'table']
name = { first = "Tom", point = { x = 1, arr = [1, 2, 3] } }
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["a"][`nes"\ted`]["table"]["name"]["first"].str() != "Tom") {
		return 1;
	}
	if (val["a"][`nes"\ted`]["table"]["name"]["point"]["x"].integer() != 1) {
		return 2;
	}
	arr := val["a"][`nes"\ted`]["table"]["name"]["point"]["arr"].array();
	if (arr.length != 3 ||
		arr[0].integer() != 1 ||
		arr[1].integer() != 2 ||
		arr[2].integer() != 3) {
		return 3;
	}
	return 0;
}
