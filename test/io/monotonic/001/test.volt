module test;

import monotonic = watt.io.monotonic;


fn main() i32
{
	if (monotonic.ticksPerSecond == 0) {
		return 1;
	}

	auto f = monotonic.ticks();
	if (f == 0) {
		return 1;
	}

	return 0;
}
