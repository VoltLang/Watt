module test;

import toml = watt.toml;
import io = watt.io;

enum TomlFile = `
[a]
x = 2
[a.b]
y = 3
[a.b.c]
z = 4
`;

fn main() i32
{
	val := toml.parse(TomlFile);
	str := val.toString();
	io.writeln(str);
	val2:= toml.parse(str);
	return val2["a"]["b"]["c"]["z"].integer() == 4 && val2["a"]["b"]["y"].integer() == 3 ? 0 : 1;
}
