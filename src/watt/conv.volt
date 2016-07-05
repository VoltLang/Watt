// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.conv;

import core.exception;
import core.stdc.stdlib : strtof, strtod;
import core.stdc.stdio : snprintf;
import core.stdc.string : strlen;
import watt.text.ascii : isDigit, isHexDigit, asciiToLower = toLower, asciiToUpper = toUpper, HEX_DIGITS;
import watt.text.format : format;
import watt.text.utf : encode;
import watt.text.sink : StringSink;


class ConvException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

string toLower(string s)
{
	StringSink dst;
	// @TODO extend to support all lowercase.
	// https://www-01.ibm.com/support/knowledgecenter/ssw_ibm_i_71/nls/rbagslowtoupmaptable.htm
	foreach (dchar c; s) {
		switch (c) {
		case 'Α': dst.sink("α"); break;
		case 'Γ': dst.sink("γ"); break;
		case 'Ω': dst.sink("ω"); break;
		default: dst.sink(encode(asciiToLower(c))); break;
		}
	}
	return dst.toString();
}

string toUpper(string s)
{
	auto ns = new char[](s.length);
	for (size_t i = 0; i < s.length; i++) {
		ns[i] = cast(char) asciiToUpper(s[i]);
	}
	return cast(string) ns;
}

ulong toUlong(const(char)[] s, int base = 10)
{
	if (base > 10 || base <= 0) {
		if (base != 16) {
			throw new ConvException(format("Don't know how to handle base %s.", base));
		}
	}
	ulong integer;
	ulong column = 1;
	for (size_t i = s.length; i > 0; i--) {
		char c = s[i - 1];
		if (base != 16 && !isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		ulong digit;
		if (isDigit(c)) {
			digit = (cast(ulong)c) - (cast(ulong)'0');
		} else if (isHexDigit(c)) {
			auto lowerC = asciiToLower(c);
			digit = 10 + ((cast(ulong)lowerC) - (cast(ulong)'a'));
		}
		if (digit >= cast(ulong)base) {
			throw new ConvException(format("Invalid digit %s for base %s.", digit, base));
		}
		integer += digit * cast(ulong)column;
		column *= cast(ulong) base;
	}
	return integer;
}

long toLong(const(char)[] s, int base = 10)
{
	long multiply = 1;
	if (s.length > 0 && s[0] == '-') {
		s = s[1 .. $];
		multiply = -1;
	}
	auto v = cast(long)toUlong(s, base);
	return v * multiply;
}

int toInt(const(char)[] s, int base = 10)
{
	auto v = toLong(s, base);
	return cast(int)v;
}

uint toUint(const(char)[] s, int base = 10)
{
	auto v = toUlong(s, base);
	return cast(uint)v;
}

float toFloat(string s)
{
	const(char)* cstr = toStringz(s);
	return strtof(cstr, null);
}

double toDouble(string s)
{
	const(char)* cstr = toStringz(s);
	return strtod(cstr, null);
}

const(char)[] toString(ubyte b)
{
	return toStringUnsigned(b, 3);
}

const(char)[] toString(byte b)
{
	return toStringSigned(b, 4);
}

const(char)[] toString(ushort s)
{
	return toStringUnsigned(s, 5);
}

const(char)[] toString(short s)
{
	return toStringSigned(s, 6);
}

const(char)[] toString(uint i)
{
	return toStringUnsigned(i, 10);
}

const(char)[] toString(int i)
{
	return toStringSigned(i, 11);
}

const(char)[] toString(ulong l)
{
	return toStringUnsigned(l, 19);
}

const(char)[] toString(long l)
{
	return toStringSigned(l, 20);
}

const(char)[] toString(float f)
{
	char[1024] buf;
	int retval = snprintf(buf.ptr, buf.length, "%f", f);

	if (retval < 0) {
		throw new ConvException("couldn't convert float to string.");
	}
	return new string(buf[0 .. cast(size_t)retval]);
}

const(char)[] toString(double d)
{
	char[1024] buf;
	int retval = snprintf(buf.ptr, buf.length, "%f", d);

	if (retval < 0) {
		throw new ConvException("couldn't convert double to string.");
	}
	return new string(buf[0 .. cast(size_t)retval]);
}

const(char)[] toString(void* p)
{
	auto u = cast(size_t) p;
	return "0x" ~ toStringHex(u);
}

const(char)[] toString(bool b)
{
	return b ? "true" : "false";
}

const(char)[] charToString(dchar c)
{
	if ((cast(uint) c) >= 255) {
		throw new Error("charToString: non ASCII dchars unimplemented.");
	}
	auto buf = new char[](1);
	buf[0] = cast(char) c;
	return cast(const(char)[]) buf;
}

// maxLength == maximum length of output string, including '-' for signed integers.

private const(char)[] toStringUnsigned(ulong i, size_t maxLength)
{
	size_t index = 0u;
	auto buf = new char[](maxLength);

	bool inLoop = true;
	while (inLoop) {
		ulong remainder = i % 10;
		char c = cast(char)(cast(ulong)'0' + remainder);
		i = i / 10;
		buf[index++] = c;
		inLoop = i != 0;
	}
	buf = buf[0 .. index];

	auto outbuf = new char[](maxLength);
	size_t bindex = index;
	size_t oindex = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}

	return outbuf[0 .. oindex];
}

private const(char)[] toStringSigned(long i, size_t maxLength)
{
	size_t index = 0u;
	auto buf = new char[](maxLength);
	bool negative = i < 0;
	if (negative) {
		i = i * -1;
	}
	
	bool inLoop = true;
	while (inLoop) {
		long remainder = i % 10;
		char c = cast(char)(cast(long)'0' + remainder);
		i = i / 10;
		buf[index++] = c;
		inLoop = i != 0;
	}
	if (negative) {
		buf[index++] = '-';
	}
	buf = buf[0 .. index];

	auto outbuf = new char[](maxLength);
	size_t bindex = index;
	size_t oindex = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}

	return outbuf[0 .. oindex];
}

/// Returns an upper case hex string from the given unsigned long.
const(char)[] toStringHex(ulong i)
{
	auto buf = new char[](0);

	bool inLoop = true;
	while (inLoop) {
		ulong remainder = i % 16;
		char c = HEX_DIGITS[remainder];
		i = i / 16;
		buf ~= c;
		inLoop = i != 0;
	}

	auto outbuf = new char[](buf.length);
	size_t bindex = buf.length;
	size_t oindex = 0u;
	while (oindex != buf.length) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}

	return outbuf;
}

/**
 * Given a Volt string s, return a pointer to a nul terminated string.
 */
const(char)* toStringz(const(char)[] s)
{
	auto cstr = new char[](s.length + 1);
	cstr[0 .. $-1] = s[0 .. $];
	cstr[$ - 1] = '\0';
	return cast(const(char)*) cstr.ptr;
}

/**
 * Given a nul terminated string s, return a Volt string.
 */
string toString(scope const(char)* s)
{
	if (s is null) {
		return null;
	}

	auto str = new char[](strlen(s));
	str[] = s[0 .. str.length];
	return cast(string) str;
}

string toString(const(char)* s)
{
	if (s is null) {
		return null;
	}

	auto str = new char[](strlen(s));
	str[] = s[0 .. str.length];
	return cast(string) str;
}
