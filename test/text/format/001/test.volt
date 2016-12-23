//T compiles:yes
//T retval:42
module test;

import watt.text.format;


int main()
{
	foo := 16;
	i16 bar = 10;

	if (format("%s %s", foo, foo) != "16 16") {
		return 1;
	}

	if (format("%s %s", bar, bar) != "10 10") {
		return 2;
	}

	if (format("%x %x", foo, foo) != "10 10") {
		return 3;
	}

	if (format("%x %x", bar, bar) != "a a") {
		return 4;
	}

	if (format("%X %X", bar, bar) != "A A") {
		return 5;
	}

	return 42;
}
