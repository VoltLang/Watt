import watt.io;

fn foo(n: i32)
{
	if (n < 100) {
		return;
	}
	writeln("big n");
}

fn main() i32
{
	foo(101);
	foo(50);
	return 0;
}
