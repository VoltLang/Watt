module test;

import toml = watt.toml;

global src := `
[[fruit]]
  name = "apple"

  [fruit.physical]
    colour = "red"
    shape = "round"

`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	arr := val["fruit"].array();
	if (arr.length != 1) {
		return 1;
	}
	if (arr[0]["name"].str() != "apple") {
		return 2;
	}
	if (arr[0]["physical"]["colour"].str() != "red") {
		return 3;
	}
	if (arr[0]["physical"]["shape"].str() != "round") {
		return 4;
	}
	return 0;
}
