//T macro:expect-failure
//T check:cannot modify
module test;

fn main() i32
{
	a: const(i32) = 12;
	a = 6;
	return a - 6;
}
