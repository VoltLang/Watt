import watt.io;

fn main() i32
{
	a := [2];
	foreach (ref i; a) {
		i *= 3;
	}
	writeln(a[0]);
	return 0;
}
