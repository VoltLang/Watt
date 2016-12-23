//T compiles:yes
//T retval:3
module test;

import watt.text.string;

int main(string[] args) {
	return endsWith("abc", "abc", "bc") + startsWith("hello", "hell");
}

