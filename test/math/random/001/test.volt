//T compiles:yes
//T retval:42
module test;

import watt.math.random;
import watt.io;

int main()
{
	MersenneTwisterEngine mte;
	mte.seed(42);

	// Clearly this test is not enough, but it caches obvious errors.
	foreach (v; [1608637542U, 3421126067U, 4083286876U, 787846414U]) {
		if (mte.front != v) {
			return 0;
		}
		mte.popFront();
	}

	return 42;
}
