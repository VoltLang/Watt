module test;

import io = watt.io;
import toml = watt.toml;
import text = watt.text.string;

enum src = `[[fruit]]
  name = "apple"

# Hello World
# Multiline drifting
  [fruit.physical]
    colour = "red"
    shape = "round"

  [[fruit.variety]]
    name = "red delicious"

  [[fruit.variety]]
    name = "granny smith"

[[fruit]]
  name = "banana"

  [[fruit.variety]]
    name = "plantain"`;

enum dst = `[[fruit]]
name = "apple"
# Hello World
# Multiline drifting
[fruit.physical]
colour = "red"
shape = "round"
[[fruit.variety]]
name = "red delicious"
[[fruit.variety]]
name = "granny smith"
[[fruit]]
name = "banana"
[[fruit.variety]]
name = "plantain"`;

fn main() i32
{
	val := toml.parse(src);
	_out := val.toString();
	_out = text.strip(_out);
	_out = text.replace(_out, "\r\n", "\n");
	_in := text.strip(dst);
	_in = text.replace(_in, "\r\n", "\n");
	if (_out != _in) {
		return 1;
	}
	return 0;
}
