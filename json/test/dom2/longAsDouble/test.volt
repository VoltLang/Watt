module test;

import json = watt.json.dom2;

enum jsonString = `
{
	"a": 3.1415926538,
	"b": 2.5345632345,
	"c": 7
}
`;

fn main(args: string[]) i32
{
	root := json.parse(jsonString);
	sum := root.byKey("a").asDouble + root.byKey("b").asDouble + root.byKey("c").asDouble;
	if (sum < 12 || sum >= 13) {
		return 1;
	} 
	return 0;
}
