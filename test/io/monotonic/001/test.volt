//T compiles:yes
//T retval:42
module test;

import monotonic = watt.io.monotonic;


int main()
{
	if (monotonic.ticksPerSecond == 0) {
		return 0;
	}

	auto f = monotonic.ticks();
	if (f == 0) {
		return 0;
	}

	return 42;
}
