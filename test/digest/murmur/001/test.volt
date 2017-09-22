//T macro:import
module test;

import mtest;

global tests := [
	["", "00000000"],
	["a", "3C2569B2"],
	["ab", "9BBFD75F"],
	["abc", "B3DD93FA"],
	["abcd", "43ED676A"],
	["abcde", "E89B9AF6"],
	["abcdef", "6181C085"],
	["abcdefg", "883C9B06"],
	["abcdefgh", "49DDCCC4"],
	["abcdefghi", "421406F0"],
	["abcdefghij", "88927791"],
	["abcdefghijk", "5F3B25DF"],
	["abcdefghijkl", "A36F3D27"],
	["abcdefghijklm", "F212161B"],
	["abcdefghijklmn", "F8526DF0"],
	["abcdefghijklmno", "9D09F7D2"],
	["abcdefghijklmnop", "E76291ED"],
	["abcdefghijklmnopq", "B6655E4A"],
	["abcdefghijklmnopqr", "C219A894"],
	["abcdefghijklmnopqrs", "85BF5BC1"],
	["abcdefghijklmnopqrst", "BE1C719A"],
	["abcdefghijklmnopqrstu", "5A19E7AB"],
	["abcdefghijklmnopqrstuv", "70B63CC7"],
	["abcdefghijklmnopqrstuvw", "A51E4D1C"],
	["abcdefghijklmnopqrstuvwx", "B0F93939"],
	["abcdefghijklmnopqrstuvwxy", "3883561A"],
	["abcdefghijklmnopqrstuvwxyz", "A34E036D"]
];

fn main() i32
{
	foreach (test; tests) {
		if (!checkResult(test[0], test[1])) {
			return 1;
		}
	}
	return 0;
}
