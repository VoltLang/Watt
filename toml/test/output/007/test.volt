module test;

import toml = watt.toml;
import io = watt.io;

enum TomlFile = `
[a.b]
x = 2
[a]
y = 3
`;

fn main() i32
{
	val := toml.parse(TomlFile);
	str := val.toString();
	io.writeln(str);
	val2:= toml.parse(str);
	return val2["a"]["y"].integer() == 3 ? 0 : 1;
}