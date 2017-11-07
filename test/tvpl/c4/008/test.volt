//T macro:expect-failure
//T check:cannot implicitly convert
module test;

fn main() i32
{
	i: i32 = 12;
	ip: immutable(i32)* = &i;
	return i - 12;
}
