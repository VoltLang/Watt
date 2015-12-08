// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.math.introspection;


int isnan(double d)
{
	return d != d;
}

int isnan(float f)
{
	return f != f;
}

int isinf(double d)
{
	return !isnan(d) && isnan(d - d);
}

int isinf(float f)
{
	return !isnan(f) && isnan(f - f);
}
