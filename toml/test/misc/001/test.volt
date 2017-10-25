module test;

import toml = watt.toml;

enum src = `
keya = "valuea"
keyb = "valueb"
[tablea]
keyc = "valuec"
`;

fn main() i32
{
	val := toml.parse(src);
	keys := val.tableKeys();
	values := val.tableValues();
	assert(keys.length == values.length);
	assert(keys.length == 3);
	one, two, three: bool;
	foreach (i, key; keys) {
		switch (key) {
		case "keya":
			if (one) {
				return 1;
			}
			one = values[i].str() == "valuea";
			break;
		case "keyb":
			if (two) {
				return 2;
			}
			two = values[i].str() == "valueb";
			break;
		case "tablea":
			if (three) {
				return 3;
			}
			three = values[i]["keyc"].str() == "valuec";
			break;
		default:
			return 4;
		}
	}
	if (!one || !two || !three) {
		return 5;
	}
	return 0;
}
