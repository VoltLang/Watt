module test;

import watt.io;
import watt.text.string;

fn main() i32
{
	if ("\\a\\".replace("\\", "\\\\") == "\\\\a\\\\" &&
		"fruit".replace("rui", "bar") == "fbart" &&
		"fruit".replace("blar", "blar") == "fruit") {
		return 0;
	}

	return 1;
}
