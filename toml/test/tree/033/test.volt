module test;

import toml = watt.toml;

enum TOMLFILE = `
[[a.b]]
val = 12
[[a.b]]
val = 24
`;

fn main() i32
{
	root := toml.parse(TOMLFILE);
	arr := root["a"]["b"].array();
	if (arr.length != 2) {
		return 1;
	}
	if (arr[0]["val"].integer() != 12) {
		return 2;
	}
	if (arr[1]["val"].integer() != 24) {
		return 3;
	}
	return 0;
}
