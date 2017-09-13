module test;

import io = watt.io;
import toml = watt.toml;
import text = watt.text.string;

enum src = `point = {x = 2, y = 3}
points = [{x = 1, y = 2}, {y = 3, x = [1, 2, 3]}]`;

enum dst = `point = {x = 2, y = 3}
points = [{x = 1, y = 2}, {y = 3, x = [1, 2, 3]}]`;

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
