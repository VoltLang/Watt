// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.math.floating;


// Can't fit more bits into floats and double, yes really.
enum float PIf = 3.141592653589793238462643383279502884197169399375105820974944;
enum double PI = 3.141592653589793238462643383279502884197169399375105820974944;

extern(C) double sin(double);
extern(C) float sinf(float);
alias sin = sinf;

extern(C) double cos(double);
extern(C) float cosf(float);
alias cos = cosf;

extern(C) double sqrt(double);
extern(C) float sqrtf(float);
alias sqrt = sqrtf;
