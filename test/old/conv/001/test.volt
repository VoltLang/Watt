//T compiles:yes
//T retval:5
module test;

import watt.conv;

int main() {
	return toInt("-10") + toInt("15");
}
