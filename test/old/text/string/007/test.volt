//T compiles:yes
//T retval:100
// Tests indexOf.
module test;

import watt.text.string;

int main()
{
	if (indexOf("abcdefg", 'd') != 3) {
		return 0;
	}
	if (indexOf("abcdeeee", 'e') != 4) {
		return 1;
	}
	if (indexOf("", 'x') != -1) {
		return 2;
	}
	if (indexOf("hello", 'x') != -1) {
		return 3;
	}
	if (indexOf("これはテストだよ", 'れ') != 3) {
		return 4;
	}
	if (indexOf("hello world", "world") != 6) {
		return 5;
	}
	if (indexOf("hello worl", "world") != -1) {
		return 6;
	}
	if (indexOf("", "") != -1) {
		return 7;
	}
	if (indexOf("", "world") != -1) {
		return 8;
	}
	if (indexOf("hello world", "") != -1) {
		return 9;
	}
	if (indexOf("悪因悪果", "悪果") != 6) {
		return 10;
	}

	return 100;
}

