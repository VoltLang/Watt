import watt.io;

struct S
{
	x: i32;
}

fn twiddle(s: S)
{
	s.x = 12;
}

fn main() i32
{
	s: S;
	s.x = 6;
	twiddle(s);
	writeln(s.x);
	return 0;
}
