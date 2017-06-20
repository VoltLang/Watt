// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Floating point maths functions.
module watt.math.floating;

// Floats and double hold the same amount of bits. Really!
/*!
 * The number PI as a constant.
 * @{
 */
enum f32 PIf = 3.141592653589793238462643383279502884197169399375105820974944;
enum f64 PI = 3.141592653589793238462643383279502884197169399375105820974944;
//! @}

/*!
 * Calculate the sine function of a number.
 * @{
 */
extern(C) fn sin(f64) f64;
extern(C) fn sinf(f32) f32;
alias sin = sinf;
//! @}

/*!
 * Calculate the cosine function of a number.
 * @{
 */
extern(C) fn cos(f64) f64;
extern(C) fn cosf(f32) f32;
alias cos = cosf;
//! @}

/*!
 * Calculate the tangent function of a number.
 * @{
 */
extern(C) fn tan(f64) f64;
extern(C) fn tanf(f32) f32;
alias tan = tanf;
//! @}

/*!
 * Calculate the square root of a number.
 * @{
 */
extern(C) fn sqrt(f64) f64;
extern(C) fn sqrtf(f32) f32;
alias sqrt = sqrtf;
//! @}

//! Convert radians into degrees.
fn radians(degs: f64) f64
{
	return (PI * degs) / 180.0;
}

//! Convert degrees into radians.
fn degrees(rads: f64) f64
{
	return (180.0 * rads) / PI;
}

/*!
 * Round a value down.
 * @{
 */
@mangledName("llvm.floor.f32") fn floor(f32) f32;
@mangledName("llvm.floor.f64") fn floor(f64) f64;
//! @}
/*!
 * Round a value up.
 * @{
 */
@mangledName("llvm.ceil.f32") fn ceil(f32) f32;
@mangledName("llvm.ceil.f64") fn ceil(f64) f64;
//! @}
/*!
 * Round a value to the nearest integer.
 * @{
 */
@mangledName("llvm.round.f32") fn round(f32) f32;
@mangledName("llvm.round.f64") fn round(f64) f64;
//! @}
