import watt.io;

fn main() i32
{
	scope (exit) {
		writeln("bye!");
	}
	writeln("hi!");
	return 0;
}
