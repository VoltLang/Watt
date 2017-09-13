module test;

import io = watt.io;
import toml = watt.toml;

enum src = `[[fruit]]
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
    name = "plantain"`;

fn main() i32
{
	val1 := toml.parse(src);
	val2 := toml.parse(val1.toString());

	arr1 := val2["fruit"].array();
	if (arr1.length != 2) {
		return 1;
	}
	if (arr1[0]["name"].str() != "apple") {
		return 2;
	}

	arr2 := arr1[0]["variety"].array();
	if (arr2.length != 2) {
		return 3;
	}
	if (arr2[0]["name"].str() != "red delicious") {
		return 4;
	}
	if (arr2[1]["name"].str() != "granny smith") {
		return 5;
	}

	if (arr1[1]["name"].str() != "banana") {
		return 6;
	}

	arr3 := arr1[1]["variety"].array();
	if (arr3[0]["name"].str() != "plantain") {
		return 7;
	}

	return 0;
}
