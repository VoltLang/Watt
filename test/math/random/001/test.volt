module test;

import watt.math.random;
import watt.io;

fn main() i32
{
	MersenneTwisterEngine mte;
	mte.seed(42);

	// Clearly this test is not enough, but it catches obvious errors.
	foreach (v; [1608637542U, 3421126067U, 4083286876U, 787846414U]) {
		if (mte.front != v) {
			return 1;
		}
		mte.popFront();
	}

	return 0;
}
