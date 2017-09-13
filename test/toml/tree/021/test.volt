module test;

import toml = watt.toml;

global src := `
[[products]]
name = "Hammer"
sku = 738594937

[[products]]

[[products]]
name = "Nail"
sku = 284758393
colour = "grey"
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	arr := val["products"].array();
	if (arr.length != 3) {
		return 1;
	}
	if (arr[0]["name"].str() != "Hammer" ||
		arr[0]["sku"].integer() != 738594937) {
		return 2;
	}
	if (arr[1].countKeys() != 0) {
		return 3;
	}
	if (arr[2]["name"].str() != "Nail" ||
		arr[2]["sku"].integer() != 284758393 ||
		arr[2]["colour"].str() != "grey") {
		return 4;
	}
	return 0;
}
