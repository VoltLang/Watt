module test;

import toml = watt.toml;

global src := `
arr = [ [ 5, 8 ], [ "all", 'strings', """are the same""", '''type''']]
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	arr := val["arr"].array();
	if (arr.length != 2) {
		return 1;
	}
	arr0 := arr[0].array();
	if (arr0.length != 2 ||
		arr0[0].integer() != 5 ||
		arr0[1].integer() != 8) {
		return 2;
	}
	arr1 := arr[1].array();
	if (arr1.length != 4 ||
		arr1[0].str() != "all" ||
		arr1[1].str() != "strings" ||
		arr1[2].str() != "are the same" ||
		arr1[3].str() != "type") {
		return 3;
	}
	return 0;
}
