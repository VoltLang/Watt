//T macro:expect-failure
//T check:cannot implicitly
module test;

fn main() i32
{
	ia: immutable(i32[]);
	ib: i32[] = ia;
	return 0;
}
