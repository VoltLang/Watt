import watt.io;

fn add(integers: i32[]...) i32
{
	sum: i32;
	foreach (integer; integers) {
		sum += integer;
	}
	return sum;
}

fn main() i32
{
	writeln(add(1, 2, 3));
	writeln(add([1, 2, 3]));
	return 0;
}
