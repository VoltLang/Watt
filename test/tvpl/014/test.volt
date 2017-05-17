//T default:no
//T macro:expect-failure
import watt.io;

fn main() i32
{
	a := 1;
	{
		writeln(a);  // 1
		b := 2;
		writeln(b);  // 2
	}
	writeln(b);  // ERROR: no variable 'b' defined.
	return 0;
}
