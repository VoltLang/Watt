// Test simple things that json.dom should successfuly parse.
module test;

import watt.io;
import watt.json;

fn main() i32
{
	auto empty = parse("{}");
	if (empty.keys().length > 0) {
		return 1;
	}
	auto simple = parse(`{ "ame": true }`);
	if (!simple.lookupObjectKey("ame").boolean()) {
		return 2;
	}
	auto str = parse(`{ "ga": "futteiru" }`);
	if ( str.lookupObjectKey("ga").str() != "futteiru") {
		return 3;
	}
	auto dbl = parse(`{ "shikata" : 3.14159263 }`);
	auto v = dbl.lookupObjectKey("shikata");
	if (v.floating() < 3.1 || v.floating() >= 3.2 ) {
		return 4;
	}
	auto lng = parse(`{ "ga": -32 }`);
	auto l = lng.lookupObjectKey("ga");
	if (l.integer() != -32) {
		return 5;
	}
	auto arr = parse(`{ "nai": [{"hello": null}] }`);
	auto aa = arr.lookupObjectKey("nai");
	auto aok = aa.array()[0].lookupObjectKey("hello");
	if (!aok.isNull()) {
		return 6;
	}
	auto objobj = parse(`{ "wagahai": {"wa":2} }`);
	auto obj = objobj.lookupObjectKey("wagahai");
	if (obj.lookupObjectKey("wa").integer() != 2) {
		return 7;
	}
	auto ulng = parse(`{ "neko": 9223372036854775887 }`);
	auto ul = ulng.lookupObjectKey("neko");
	if (ul.unsigned() != 9223372036854775887UL) {
		return 8;
	}
	auto esc = parse(`{ "dearu": "\t\t\"" }`);
	auto es = esc.lookupObjectKey("dearu");
	if (es.str() != "		\"") {
		return 9;
	}
	return 0;
}

