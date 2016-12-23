//T compiles:yes
//T retval:32
module test;

import watt.algorithm;

int main()
{
	return max(min(cast(int)max(0.0, 32.0), 64), min(16, max(16, 16)));
}
