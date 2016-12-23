//T compiles:yes
//T retval:24
module test;

import watt.text.string;

int main()
{
	if (join(["hello", "world"]) != "helloworld") {
		return 0;
	}
	if (join([], " ") != "") {
		return 1;
	}
	if (["a", "b", "c"].join("XXX") != "aXXXbXXXc") {
		return 2;
	}
	return 24;
}
