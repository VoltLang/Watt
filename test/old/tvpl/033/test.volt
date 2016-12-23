import watt.io;

class Person
{
	fn sayHello()
	{
		writeln("I am a person. Hi!");
	}
}

class Doctor : Person
{
	override fn sayHello()
	{
		writeln("I am a person who is also a doctor. Hi!");
	}
}

fn main() i32
{
	p1: Person = new Person();
	p2: Person = new Doctor();
	p1.sayHello();
	p2.sayHello();
	return 0;
}
