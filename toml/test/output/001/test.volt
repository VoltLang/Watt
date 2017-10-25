module test;

import io = watt.io;
import toml = watt.toml;

enum src = `
"a key" = "value"
[a]
key = "value"
[b]
key2 = "value"
key3 = "value"
[b."dog man"]
x = 32
point = { "x" = "value", "y" = "value" }
`;

fn main() i32
{
	val1 := toml.parse(src);
	val2 := toml.parse(val1.toString());
	if (val2["a key"].str() != "value") {
		return 1;
	}
	if (val2["a"]["key"].str() != "value") {
		return 2;
	}
	if (val2["b"]["key2"].str() != "value" ||
		val2["b"]["key3"].str() != "value") {
		return 3;
	}
	if (val2["b"]["dog man"]["x"].integer() != 32) {
		return 4;
	}
	if (val2["b"]["dog man"]["point"]["x"].str() != "value" ||
		val2["b"]["dog man"]["point"]["y"].str() != "value") {
		return 5;
	}
	return 0;
}
