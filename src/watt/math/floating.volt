// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.math.floating;


/**
 * The number PI as a constant.
 * Can't fit more bits into floats and double, yes really.
 * @{
 */
enum f32 PIf = 3.141592653589793238462643383279502884197169399375105820974944;
enum f64 PI = 3.141592653589793238462643383279502884197169399375105820974944;
/// @}

extern(C) fn sin(f64) f64;
extern(C) fn sinf(f32) f32;
alias sin = sinf;

extern(C) fn cos(f64) f64;
extern(C) fn cosf(f32) f32;
alias cos = cosf;

extern(C) fn tan(f64) f64;
extern(C) fn tanf(f32) f32;
alias tan = tanf;

extern(C) fn sqrt(f64) f64;
extern(C) fn sqrtf(f32) f32;
alias sqrt = sqrtf;

fn radians(degs: f64) f64
{
	return (PI * degs) / 180.0;
}

fn degrees(rads: f64) f64
{
	return (180.0 * rads) / PI;
}

@mangledName("llvm.floor.f32") fn floor(f32) f32;
@mangledName("llvm.floor.f64") fn floor(f64) f64;
