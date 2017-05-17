module test;

import watt.io.file;

fn main() i32
{
	if (!globMatch("", "*")) {
		return 8;
	}
	if (globMatch("", "?")) {
		return 1;
	}
	if (!globMatch("a", "*")) {
		return 2;
	}
	if (!globMatch("a", "?")) {
		return 3;
	}
	if (!globMatch("ab", "*b")) {
		return 4;
	}
	if (!globMatch("ab", "??")) {
		return 5;
	}
	return 0;
}

