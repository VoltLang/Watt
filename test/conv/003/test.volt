//T compiles:yes
//T retval:12
module test;

import watt.conv;

int main()
{
	if (toFloat("532.67") > 532.0f && toDouble("1.2") < 2.4) {
		return 12;
	}
	return 0;
}
