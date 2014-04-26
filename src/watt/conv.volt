// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.conv;

import watt.text.ascii : isDigit, isHexDigit, asciiToLower = toLower, asciiToUpper = toUpper;
import watt.text.format : format;

class ConvException : Exception
{
	this(string msg)
	{
		super(msg);
		return;
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


int toInt(const(char)[] s, int base = 10)
{
	if (base > 10 || base <= 0) {
		if (base != 16) {
			throw new ConvException(format("Don't know how to handle base %s.", base));
		}
	}
	int integer;
	int column = 1;
	for (size_t i = s.length; i > 0; i--) {
		char c = s[i - 1];
		if (base != 16 && !isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		int digit;
		if (isDigit(c)) {
			digit = (cast(int)c) - (cast(int)'0');
		} else if (isHexDigit(c)) {
			auto lowerC = asciiToLower(c);
			digit = 10 + ((cast(int)lowerC) - (cast(int)'a'));
		}
		if (digit >= base) {
			throw new ConvException(format("Invalid digit %s for base %s.", digit, base));
		}
		integer += digit * column;
		column *= base;
	}
	return integer;
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
