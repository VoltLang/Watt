module test;

import toml = watt.toml;

global src := `
[[fruit]]
  name = "apple"

  [fruit.physical]
    colour = "red"
    shape = "round"

  [[fruit.variety]]
    name = "red delicious"

  [[fruit.variety]]
    name = "granny smith"

[[fruit]]
  name = "banana"

  [[fruit.variety]]
    name = "plantain"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	arr := val["fruit"].array();
	if (arr.length != 2) {
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
	arrarr := arr[0]["variety"].array();
	if (arrarr.length != 2) {
		return 5;
	}
	if (arrarr[0]["name"].str() != "red delicious") {
		return 6;
	}
	if (arrarr[1]["name"].str() != "granny smith") {
		return 7;
	}
	if (arr[1]["name"].str() != "banana") {
		return 8;
	}
	arrarr2 := arr[1]["variety"].array();
	if (arrarr2.length != 1) {
		return 9;
	}
	if (arrarr2[0]["name"].str() != "plantain") {
		return 10;
	}
	return 0;
}
