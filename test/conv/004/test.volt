//T compiles:yes
//T retval:0
module test;

import watt.conv;
import watt.io;

fn main() i32
{
	_u8: u8 = 0; 
	if (toStringBinary(_u8) != "00000000") {
		return 1;
	}
	_u8 = 5;
	if (toStringBinary(_u8) != "00000101") {
		return 2;
	}
	_i8: i8 = 0;
	if (toStringBinary(_i8) != "00000000") {
		return 3;
	}
	_i8 = 1;
	if (toStringBinary(_i8) != "00000001") {
		return 4;
	}
	_i8 = cast(i8)-2;
	if (toStringBinary(_i8) != "11111110") {
		return 5;
	}
	_u32: u32 = 0; 
	if (toStringBinary(_u32) != "00000000000000000000000000000000") {
		return 6;
	}
	_u32 = 256;
	if (toStringBinary(_u32) != "00000000000000000000000100000000") {
		return 7;
	}
	_i32: i32 = 0;
	if (toStringBinary(_i32) != "00000000000000000000000000000000") {
		return 8;
	}
	_i32 = 1;
	if (toStringBinary(_i32) != "00000000000000000000000000000001") {
		return 9;
	}
	_i32 = -2;
	if (toStringBinary(_i32) != "11111111111111111111111111111110") {
		return 5;
	}
	return 0;
}
