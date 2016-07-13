// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.math.floating;


// Can't fit more bits into floats and double, yes really.
enum f32 PIf = 3.141592653589793238462643383279502884197169399375105820974944;
enum f64 PI = 3.141592653589793238462643383279502884197169399375105820974944;

extern(C) fn sin(f64) f64;
extern(C) fn sinf(f32) f32;
alias sin = sinf;

extern(C) fn cos(f64) f64;
extern(C) fn cosf(f32) f32;
alias cos = cosf;

extern(C) fn sqrt(f64) f64;
extern(C) fn sqrtf(f32) f32;
alias sqrt = sqrtf;
