// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
module watt.text.utf;

class MalformedUTF8Exception : Exception
{
	this(string msg = "malformed UTF-8 stream")
	{
		super(msg);
		return;
	}
}

private enum ONE_BYTE_MASK                   = 0x80;
private enum TWO_BYTE_MASK                   = 0xE0;
private enum TWO_BYTE_RESULT                 = 0xC0;
private enum THREE_BYTE_MASK                 = 0xF0;
private enum FOUR_BYTE_MASK                  = 0xF8;
private enum FIVE_BYTE_MASK                  = 0xFC;
private enum SIX_BYTE_MASK                   = 0xFE;
private enum CONTINUING_MASK                 = 0xC0;

private ubyte readByte(string str, ref size_t index)
{
	if (index >= str.length) {
		throw new MalformedUTF8Exception("unexpected end of stream");
	}
	ubyte b = str[index];
	index = index + 1;
	return b;
}

private dchar readChar(string str, ref size_t index)
{
	ubyte b = readByte(str, ref index);
	return cast(dchar)(b & cast(ubyte)~ONE_BYTE_MASK);
}

dchar decode(string str, ref size_t index)
{
	ubyte b1 = readByte(str, ref index);
	if ((b1 & ONE_BYTE_MASK) == 0) {
		return b1;
	}

	dchar c2 = readChar(str, ref index);
	if ((b1 & TWO_BYTE_MASK) == TWO_BYTE_RESULT) {
		dchar c1 = cast(dchar)((b1 & cast(ubyte)~TWO_BYTE_MASK));
		c1 = c1 << 6;
		return c1 | c2;
	}

	dchar c3 = readChar(str, ref index);
	if ((b1 & THREE_BYTE_MASK) == TWO_BYTE_MASK) {
		dchar c1 = cast(dchar)((b1 & cast(ubyte)~THREE_BYTE_MASK));
		c1 = c1 << 12;
		c2 = c2 << 6;
		return c1 | c2 | c3;
	}

	dchar c4 = readChar(str, ref index);
	if ((b1 & FOUR_BYTE_MASK) == THREE_BYTE_MASK) {
		dchar c1 = cast(dchar)((b1 & cast(ubyte)~FOUR_BYTE_MASK));
		c1 = c1 << 18;
		c2 = c2 << 12;
		c3 = c3 << 6;
		return c1 | c2 | c3 | c4;
	}

	dchar c5 = readChar(str, ref index);
	if ((b1 & FIVE_BYTE_MASK) == FOUR_BYTE_MASK) {
		dchar c1 = cast(dchar)((b1 & cast(ubyte)~FIVE_BYTE_MASK));
		c1 = c1 << 24;
		c2 = c2 << 18;
		c3 = c3 << 12;
		c4 = c4 << 6;
		return c1 | c2 | c3 | c4 | c5;
	}

	dchar c6 = readChar(str, ref index);
	if ((b1 & SIX_BYTE_MASK) == FIVE_BYTE_MASK) {
		dchar c1 = cast(dchar)((b1 & cast(ubyte)~SIX_BYTE_MASK));
		c1 = c1 << 30;
		c2 = c2 << 24;
		c3 = c3 << 18;
		c4 = c4 << 12;
		c5 = c5 << 6;
		return c1 | c2 | c3 | c4 | c5 | c6;
	}

	throw new MalformedUTF8Exception("utf-8 decode failure");
}

/// Return how many codepoints are in a given UTF-8 string.
size_t count(string s)
{
	size_t i, length;
	while (i < s.length) {
		decode(s, ref i);
		length++;
	}
	return length;
}

void validate(string s)
{
	size_t i;
	while (i < s.length) {
		decode(s, ref i);
	}
	return;
}

/// Encode c into a given UTF-8 array.
void encode(ref char[] buf, dchar c)
{
	buf ~= .encode(c);
	return;
}

/// Encode a unicode array into utf8
string encode(dchar[] arr)
{
	char[] buf;
	foreach (dchar d; arr) {
		encode(ref buf, d);
	}
	return cast(string)buf;
}

/// Encode c as UTF-8.
string encode(dchar c)
{
	char[] buf = new char[](6);
	auto cval = cast(uint) c;

	ubyte readByte(uint a, uint b)
	{
		ubyte _byte = cast(ubyte) (a | (cval & b));
		cval = cval >> 8;
		return _byte;
	}

	if (cval <= 0x7F) {
		buf[0] = cast(char) c;
		return cast(string)new buf[0 .. 1];
	} else if (cval >= 0x80 && cval <= 0x7FF) {
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00C0, 0x001F);
		return cast(string)new buf[0 .. 2];
	} else if (cval >= 0x800 && cval <= 0xFFFF) {
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00E0, 0x000F);
		return cast(string)new buf[0 .. 3];
	} else if (cval >= 0x10000 && cval <= 0x1FFFFF) {
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00F0, 0x000E);
		return cast(string)new buf[0 .. 4];
	} else if (cval >= 0x200000 && cval <= 0x3FFFFFF) {
		buf[4] = readByte(0x0080, 0x003F);
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00F8, 0x0007);
		return cast(string)new buf[0 .. 5];
	} else if (cval >= 0x4000000 && cval <= 0x7FFFFFFF) {
		buf[5] = readByte(0x0080, 0x003F);
		buf[4] = readByte(0x0080, 0x003F);
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00FC, 0x0001);
		return cast(string)new buf[0 .. 6];
	} else {
		throw new Exception("encode: unsupported codepoint range");
	}
}

