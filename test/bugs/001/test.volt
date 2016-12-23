//T compiles:yes
//T retval:2
module test;

import watt.io.std : output;

void foo(string s) {
	output.writeln(s);
}

int main() {
	const(char)[] s = "Hello, world.";
	foo(s);
	return 2;
}

