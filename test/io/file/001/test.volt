//T compiles:yes
//T retval:7
module test;

import watt.io.file;

int main()
{
	if (!globMatch("", "*")) {
		return 0;
	}
	if (globMatch("", "?")) {
		return 1;
	}
	if (!globMatch("a", "*")) {
		return 2;
	}
	if (!globMatch("a", "?")) {
		return 3;
	}
	if (!globMatch("ab", "*b")) {
		return 4;
	}
	if (!globMatch("ab", "??")) {
		return 5;
	}
	return 7;
}

