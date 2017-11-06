module test;

fn main() i32
{
	arr: i32[][];
	arr ~= cast(i32[])null;
	return cast(i32)arr.length - 1;
}
