module test;

import watt.text.string;

fn main() i32
{
	string[] result;
	result = split("Hello*World", '*');
	if (result.length != 2 || result[0] != "Hello" || result[1] != "World") {
		return 1;
	}
	result = split("", 'X');
	if (result.length != 0) {
		return 1;
	}
	result = split("ABC|DEF",'1');
	if (result.length != 1 || result[0] != "ABC|DEF") {
		return 2;
	}
	result = split("A  &  B &   c ", '&');
	if (result.length != 3 ||
		(result[0] != "A  " || result[1] != "  B " || result[2] != "   c ")) {
		return 3;
	}
	result = split("こんにちは*さようなら", '*');
	if (result.length != 2 ||
		(result[0] != "こんにちは" || result[1] != "さようなら")) {
		return 4;
	}
	result = split("火と地と風と水", 'と');
	if (result.length != 4 ||
		(result[0] != "火" || result[1] != "地" || result[2] != "風" ||
		result[3] != "水")) {
		return 5;
	}
	result = split("A(B(C(", '(');
	if (result.length != 4 || result[3] != "") {
		return 6;
	}
	return 0;
}

