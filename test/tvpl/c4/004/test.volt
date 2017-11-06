module test;

fn main() i32
{
	aa := [1:"hello", 2:"goodbye"];
	return (aa[1] == "hello" && aa[2] == "goodbye") ? 0 : 1;
}
