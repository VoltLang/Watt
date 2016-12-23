//T compiles:yes
//T retval:0
module test;

import watt.conv;

int main(string[] args)
{
	if (9223372036854775887UL != toUlong("9223372036854775887")) {
		return 1;
	}
	return 0;
}

