module test;

import toml = watt.toml;

fn main() i32
{
	intval := new toml.Value(32);
	strval := new toml.Value(64);
	arrval := new toml.Value([intval, strval]);
	sum := arrval.array()[0].integer() + arrval.array()[1].integer();
	return sum == 96 ? 0 : 1;
}
