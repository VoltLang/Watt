module test;

import watt.text.string;

fn main(args: string[]) i32
{
	return endsWith("abc", "abc", "bc") + startsWith("hello", "hell") - 3;
}

