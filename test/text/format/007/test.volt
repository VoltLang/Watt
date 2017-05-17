module test;

import watt.text.format : format;

fn getVoltString(d: f64) string
{
	s := format("%.f", d);
	return s;
}

fn main() i32
{
	d := 3.14159;
	if (getVoltString(d) != "3") {
		return 1;
	}
	return 0;
}
