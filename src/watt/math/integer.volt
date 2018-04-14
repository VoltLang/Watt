// Copyright 2016-2017, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
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

//! Returns the absolute value of a signed integer.
fn abs(x: i32) i32
{
	if (x < 0) {
		return x * -1;
	} else {
		return x;
	}
}
