module test;

import io = watt.io;
import toml = watt.toml;
import text = watt.text.string;

enum src = `# Comments should be preserved.
key = true
key2 = false
# Where possible.
[table]`;

fn main() i32
{
	val := toml.parse(src);
	_out := val.toString();
	_out = text.strip(_out);
	_in := text.strip(src);
	_in = text.replace(_in, "\r\n", "\n");
	_out = text.replace(_out, "\r\n", "\n");
	if (_out != _in) {
		io.writefln("%s", _out);
		return 1;
	}
	return 0;
}
