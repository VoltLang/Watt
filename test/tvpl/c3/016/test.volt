//T check:January
//T check:February
//T check:March
//T check:April
//T check:May
//T check:June
//T check:July
//T check:August
//T check:September
//T check:October
//T check:November
//T check:December
module test;

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
