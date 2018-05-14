module test;

import json = watt.json.dom2;

enum jsonString = `
{
	"hello": "world",
	"pie": 3.1415926538,
	"banana": "peel",
	"sub": {
		"arr": [1, 2, {"uh":"ok"}]
	}
}
`;

fn main(args: string[]) i32
{
	root := json.parse(jsonString);
	if (root.byKey("hello").asString != "world") {
		return 1;
	}
	if (root.byKey("banana").asString != "peel") {
		return 2;
	}
	if (root.byKey("pie").asString !is null) {
		return 3;
	}
	if (root.byKey("sub").byKey("arr").byIndex(2).byKey("uh").asString != "ok") {
		return 4;
	}
	if (root.byKey("sub").byKey("arr").byIndex(223).byKey("oh").asString !is null) {
		return 5;
	}
	return 0;
}
