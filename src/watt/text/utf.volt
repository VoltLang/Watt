// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
module watt.text.utf;

import core.rt.misc;
import core.exception;

import watt.text.sink;
import watt.text.format : format;


private enum ONE_BYTE_MASK                   = 0x80;
private enum TWO_BYTE_MASK                   = 0xE0;
private enum TWO_BYTE_RESULT                 = 0xC0;
private enum THREE_BYTE_MASK                 = 0xF0;
private enum FOUR_BYTE_MASK                  = 0xF8;
private enum FIVE_BYTE_MASK                  = 0xFC;
private enum SIX_BYTE_MASK                   = 0xFE;
private enum CONTINUING_MASK                 = 0xC0;

private fn readU8(str: string, ref index: size_t) u8
{
	if (index >= str.length) {
		throw new MalformedUTF8Exception("unexpected end of stream");
	}
	return str[index++];
}

/*
private fn readChar(str string, ref index: size_t) dchar
{
	u8 b = readU8(str, ref index);
	return cast(dchar)(b & cast(u8)~ONE_BYTE_MASK);
}
*/

fn decode(str: string, ref index: size_t) dchar
{
	return vrt_decode_u8_d(str, ref index);
}

/// Return how many codepoints are in a given UTF-8 string.
fn count(s: string) size_t
{
	i, length: size_t;
	while (i < s.length) {
		decode(s, ref i);
		length++;
	}
	return length;
}

fn validate(s: string) void
{
	i: size_t;
	while (i < s.length) {
		decode(s, ref i);
	}
}

/// Encode c into a given UTF-8 array.
fn encode(ref buf: char[], c: dchar) void
{
	str := .encode(c);
	newbuf := new char[](buf.length + str.length);
	newbuf[0 .. buf.length] = buf;
	newbuf[buf.length .. $] = str;
	buf = newbuf;
}

/// Encode a unicode array into utf8
fn encode(arr: dchar[]) string
{
	buf: char[];
	foreach (dchar d; arr) {
		encode(ref buf, d);
	}
	return cast(string)buf;
}

/// Encode c as UTF-8.
fn encode(c: dchar) string
{
	ret: string;
	fn dgt(s: SinkArg) void {
		ret = new string(s);
	}

	encode(dgt, c);
	return ret;
}

/// Encode c as UTF-8.
fn encode(dgt: Sink, c: dchar) void
{
	buf: char[6];
	cval := cast(uint) c;

	fn readU8(a: u32, b: u32) u8
	{
		_byte := cast(u8) (a | (cval & b));
		cval = cval >> 6;
		return _byte;
	}

	if (cval <= 0x7F) {
		buf[0] = cast(char) c;
		return dgt(buf[0 .. 1]);
	} else if (cval >= 0x80 && cval <= 0x7FF) {
		buf[1] = readU8(0x0080, 0x003F);
		buf[0] = readU8(0x00C0, 0x001F);
		return dgt(buf[0 .. 2]);
	} else if (cval >= 0x800 && cval <= 0xFFFF) {
		buf[2] = readU8(0x0080, 0x003F);
		buf[1] = readU8(0x0080, 0x003F);
		buf[0] = readU8(0x00E0, 0x000F);
		return dgt(buf[0 .. 3]);
	} else if (cval >= 0x10000 && cval <= 0x1FFFFF) {
		buf[3] = readU8(0x0080, 0x003F);
		buf[2] = readU8(0x0080, 0x003F);
		buf[1] = readU8(0x0080, 0x003F);
		buf[0] = readU8(0x00F0, 0x000E);
		return dgt(buf[0 .. 4]);
	} else if (cval >= 0x200000 && cval <= 0x3FFFFFF) {
		buf[4] = readU8(0x0080, 0x003F);
		buf[3] = readU8(0x0080, 0x003F);
		buf[2] = readU8(0x0080, 0x003F);
		buf[1] = readU8(0x0080, 0x003F);
		buf[0] = readU8(0x00F8, 0x0007);
		return dgt(buf[0 .. 5]);
	} else if (cval >= 0x4000000 && cval <= 0x7FFFFFFF) {
		buf[5] = readU8(0x0080, 0x003F);
		buf[4] = readU8(0x0080, 0x003F);
		buf[3] = readU8(0x0080, 0x003F);
		buf[2] = readU8(0x0080, 0x003F);
		buf[1] = readU8(0x0080, 0x003F);
		buf[0] = readU8(0x00FC, 0x0001);
		return dgt(buf[0 .. 6]);
	} else {
		throw new MalformedUTF8Exception("encode: unsupported codepoint range");
	}
}
