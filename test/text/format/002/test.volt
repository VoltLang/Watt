module test;

import watt.text.format;

fn main() i32
{
	if (format("%3d", 1) != "  1") {
		return 1;
	}
	if (format("%02x", 10) != "0a") {
		return 2;
	}
	if (format("%03s", "hi") != "0hi") {
		return 3;
	}
	if (format("%5X", 10) != "    A") {
		return 4;
	}
	return 0;
}
