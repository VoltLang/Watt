import watt.io;

interface IntGetter
{
	fn getInt() i32;
}

interface StringGetter
{
	fn getString() string;
}

class TheClass : IntGetter, StringGetter
{
	override fn getInt() i32
	{
		return 1;
	}
	
	override fn getString() string
	{
		return "watermelon";
	}
}

fn doInt(ig: IntGetter)
{
	writeln(ig.getInt());
}

fn doString(sg: StringGetter)
{
	writeln(sg.getString());
}

fn main() i32
{
	tc := new TheClass();
	doInt(tc);
	doString(tc);
	return 0;
}
