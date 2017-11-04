import watt.io;

fn main() i32
{
	fn greet(name: string)
	{
		writefln("Hello %s.", name);
	}
	
	greet("Jill");
	greet("Bob");
	return 0;
}
