module test;

import watt.text.string;

fn main() i32
{
	if (join(["hello", "world"]) != "helloworld") {
		return 4;
	}
	if (join(null, " ") != "") {
		return 1;
	}
	if (["a", "b", "c"].join("XXX") != "aXXXbXXXc") {
		return 2;
	}
	return 0;
}
