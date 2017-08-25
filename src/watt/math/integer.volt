// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Integer maths functions.
module watt.math.integer;


//! Returns the log2 fo the given unsigned integer, does not throw on 0.
fn log2(x: u32) u32
{
	ans: u32 = 0;
	while (x = x >> 1) {
		ans++;
	}

	return ans;
}
