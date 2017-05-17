module test;

import watt.text.string;

fn main() i32
{
	return cast(int)(lastIndexOf("adbcde", 'd') + lastIndexOf("", 'x')) - 3;
}
