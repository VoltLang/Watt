import watt.io;
	
fn main() i32
{
	months := ["January", "February", "March", "April", "May",
		"June", "July", "August", "September", "October", "November", "December"];
	foreach (month; months) {
		writeln(month);
	}
	return 0;
}
