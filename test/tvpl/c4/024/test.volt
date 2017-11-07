//T macro:expect-failure
//T check:cannot implicitly convert
module test;

fn main() i32
{
	a: i32;
	b: i16;
	b = a;
	return a;
}
