// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
//! Functions for decoding and encoding unicode strings and characters.
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

//! Return how many codepoints are in a given UTF-8 string.
fn count(s: string) size_t
{
	i, length: size_t;
	while (i < s.length) {
		decode(s, ref i);
		length++;
	}
	return length;
}

//! Throws a MalformedUTF8Exception if @p s is not valid UTF-8.
fn validate(s: string) void
{
	i: size_t;
	while (i < s.length) {
		decode(s, ref i);
	}
}

//! Encode c into a given UTF-8 array.
fn encode(ref buf: char[], c: dchar) void
{
	tmp: char[6];
	buf = buf ~ tmp[0 .. encodeNoGC(ref tmp, c)];
}

//! Encode a unicode array into utf8
fn encode(arr: dchar[]) string
{
	buf: char[];
	foreach (dchar d; arr) {
		encode(ref buf, d);
	}
	return cast(string)buf;
}

//! Encode @p c as UTF-8 and add it to @p arr, starting at @p index.
fn encode(arr: char[], ref index: size_t, c: dchar)
{
	if (arr.length < index + 6) {
		throw new MalformedUTF8Exception("destination buffer does not have enough space.");
	}

	ptr := cast(char[6]*)&arr[index];
	index += encodeNoGC(ref *ptr, c);
}

//! Encode c as UTF-8.
fn encode(c: dchar) string
{
	tmp: char[6];
	return new string(tmp[0 .. encodeNoGC(ref tmp, c)]);
}

//! Add @p c to a sink.
fn encode(dgt: Sink, c: dchar) void
{
	tmp: char[6];
	dgt(tmp[0 .. encodeNoGC(ref tmp, c)]);
}

//! Encode c as UTF-8.
//! Needs to be called nogc due to overload bug.
alias encodeNoGC = vrt_encode_static_u8;

version (Windows) {

	import core.c.windows;

	fn convertUtf8ToUtf16(str: const(char)[]) immutable(wchar)[]
	{
		if (str.length == 0) {
			return null;
		}

		srcNum := cast(int)str.length;
		dstNum := MultiByteToWideChar(CP_UTF8, 0, str.ptr, srcNum, null, 0);
		w := new wchar[](dstNum+1);

		dstNum = MultiByteToWideChar(CP_UTF8, 0,
			str.ptr, -1, w.ptr, dstNum);
		w[dstNum] = 0;
		w = w[0 .. dstNum];
		return cast(immutable(wchar)[])w;
	}

	fn convertUtf16ToUtf8(w: const(wchar)[]) string
	{
		if (w.length == 0) {
			return null;
		}

		srcNum := cast(int)w.length;
		dstNum := WideCharToMultiByte(CP_UTF8, 0, w.ptr, srcNum, null, 0, null, null);
		str := new char[](dstNum+1);

		dstNum = WideCharToMultiByte(CP_UTF8, 0,
			w.ptr, srcNum, str.ptr, dstNum, null, null);
		str[dstNum] = 0;
		str = str[0 .. dstNum];
		return cast(string)str;
	}

}
