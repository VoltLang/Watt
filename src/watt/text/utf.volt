// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
module watt.text.utf;

static import object;

import watt.text.sink;


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
		throw new object.MalformedUTF8Exception("unexpected end of stream");
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
	return object.vrt_decode_u8_d(str, ref index);
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
}

/// Encode c into a given UTF-8 array.
void encode(ref char[] buf, dchar c)
{
	buf ~= .encode(c);
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
	string ret;
	void dg(SinkArg s) {
		ret = new string(s);
	}

	encode(dg, c);
	return ret;
}

/// Encode c as UTF-8.
void encode(Sink dg, dchar c)
{
	char[6] buf;
	auto cval = cast(uint) c;

	ubyte readByte(uint a, uint b)
	{
		ubyte _byte = cast(ubyte) (a | (cval & b));
		cval = cval >> 6;
		return _byte;
	}

	if (cval <= 0x7F) {
		buf[0] = cast(char) c;
		return dg(buf[0 .. 1]);
	} else if (cval >= 0x80 && cval <= 0x7FF) {
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00C0, 0x001F);
		return dg(buf[0 .. 2]);
	} else if (cval >= 0x800 && cval <= 0xFFFF) {
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00E0, 0x000F);
		return dg(buf[0 .. 3]);
	} else if (cval >= 0x10000 && cval <= 0x1FFFFF) {
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00F0, 0x000E);
		return dg(buf[0 .. 4]);
	} else if (cval >= 0x200000 && cval <= 0x3FFFFFF) {
		buf[4] = readByte(0x0080, 0x003F);
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00F8, 0x0007);
		return dg(buf[0 .. 5]);
	} else if (cval >= 0x4000000 && cval <= 0x7FFFFFFF) {
		buf[5] = readByte(0x0080, 0x003F);
		buf[4] = readByte(0x0080, 0x003F);
		buf[3] = readByte(0x0080, 0x003F);
		buf[2] = readByte(0x0080, 0x003F);
		buf[1] = readByte(0x0080, 0x003F);
		buf[0] = readByte(0x00FC, 0x0001);
		return dg(buf[0 .. 6]);
	} else {
		throw new object.MalformedUTF8Exception("encode: unsupported codepoint range");
	}
}
