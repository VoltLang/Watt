//T check:Hello, I'm Cindy and I'm 22 years old.
module test;

import watt.io;

struct Person
{
	age: i32;
	name: string;

	fn introduceSelf()
	{
		writefln("Hello, I'm %s and I'm %s years old.", name, age);
	}
}

fn main() i32
{
	cindy: Person;
	cindy.name = "Cindy";
	cindy.age = 22;
	cindy.introduceSelf();
	return 0;
}
