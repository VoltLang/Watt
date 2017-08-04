// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Determine if floating points are special constants.
module watt.math.introspection;


/*!
 * Is the given value signalling NaN?  
 * @Returns Non-zero if `d` is nan.
 * @{
 */
fn isnan(d: f64) i32
{
	return d != d;
}

fn isnan(f: f32) i32
{
	return f != f;
}
//! @}

/*!
 * Is the given value signalling infinity?  
 * @Returns Non-zero if `d` is infinite.
 * @{
 */
fn isinf(d: f64) i32
{
	return !isnan(d) && isnan(d - d);
}

fn isinf(f: f32) i32
{
	return !isnan(f) && isnan(f - f);
}
//! @}
