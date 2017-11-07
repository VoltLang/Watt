module test;

fn main() i32
{
	i: i32 = 12;
	ip: const(i32)* = &i;
	assert(*ip == 12);
	i = 6;
	assert(*ip == 6);
	return i - 6;
}
