// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.conv;

import watt.text.ascii : isDigit, isHexDigit, asciiToLower = toLower, asciiToUpper = toUpper, HEX_DIGITS;
import watt.text.format : format;

class ConvException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

string toLower(string s)
{
	auto ns = new char[](s.length);
	for (size_t i = 0; i < s.length; i++) {
		ns[i] = cast(char) asciiToLower(s[i]);
	}
	return cast(string) ns;
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
	int column = 1;
	for (size_t i = s.length; i > 0; i--) {
		char c = s[i - 1];
		if (base != 16 && !isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		uint digit;
		if (isDigit(c)) {
			digit = (cast(uint)c) - (cast(uint)'0');
		} else if (isHexDigit(c)) {
			auto lowerC = asciiToLower(c);
			digit = 10 + ((cast(uint)lowerC) - (cast(uint)'a'));
		}
		if (digit >= cast(uint)base) {
			throw new ConvException(format("Invalid digit %s for base %s.", digit, base));
		}
		integer += digit * cast(uint)column;
		column *= base;
	}
	return integer;
}

int toInt(const(char)[] s, int base = 10)
{
	auto v = toUlong(s, base);
	return cast(int)v;
}

/**
 * @todo actually implement
 */
float toFloat(string)
{
	return 0.0f;
}

/**
 * @todo actually implement
 */
double toDouble(string)
{
	return 0.0;
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

const(char)[] toString(void* p)
{
	auto u = cast(size_t) p;
	return "0x" ~ toStringHex(u);
}

const(char)[] charToString(dchar c)
{
	if ((cast(uint) c) >= 255) {
		throw new object.Error("charToString: non ASCII dchars unimplemented.");
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
	buf.length = index;

	auto outbuf = new char[](maxLength);
	size_t bindex = index;
	size_t oindex = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}
	outbuf.length = oindex;

	return outbuf;
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
	buf.length = index;

	auto outbuf = new char[](maxLength);
	size_t bindex = index;
	size_t oindex = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}
	outbuf.length = oindex;

	return outbuf;
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

private extern (C) size_t strlen(scope const(char)* s);

/**
 * Given a nul terminated string s, return a Volt string.
 */
string toString(scope const(char)* s)
{
	auto str = new char[](strlen(s));
	str[] = s[0 .. str.length];
	return cast(string) str;
}

string toString(const(char)* s)
{
	auto str = new char[](strlen(s));
	str[] = s[0 .. str.length];
	return cast(string) str;
}
