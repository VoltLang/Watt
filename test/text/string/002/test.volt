//T compiles:yes
//T retval:36
module test;

import watt.text.string;

int main()
{
	if (splitLines("a\nb\rc\r\nd") != ["a", "b", "c", "d"]) {
		return 0;
	}
	if (splitLines("") != null) {
		return 1;
	}
	return 36;
}
