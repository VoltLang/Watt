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
	this(msg : string)
	{
		super(msg);
	}
}

fn toLower(s : string) string
{
	dst : StringSink;
	// @TODO extend to support all lowercase.
	// https://www-01.ibm.com/support/knowledgecenter/ssw_ibm_i_71/nls/rbagslowtoupmaptable.htm
	foreach (c : dchar; s) {
		switch (c) {
		case 'Α': dst.sink("α"); break;
		case 'Γ': dst.sink("γ"); break;
		case 'Ω': dst.sink("ω"); break;
		default: dst.sink(encode(asciiToLower(c))); break;
		}
	}
	return dst.toString();
}

fn toUpper(s : string) string
{
	ns := new char[](s.length);
	for (i : size_t = 0; i < s.length; i++) {
		ns[i] = cast(char) asciiToUpper(s[i]);
	}
	return cast(string) ns;
}

fn toUlong(s : const(char)[], base : i32 = 10) u64
{
	if (base > 10 || base <= 0) {
		if (base != 16) {
			throw new ConvException(format("Don't know how to handle base %s.", base));
		}
	}
	integer : u64;
	column : u64 = 1;
	for (i := s.length; i > 0; i--) {
		c : char = s[i - 1];
		if (base != 16 && !isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		digit : u64;
		if (isDigit(c)) {
			digit = (cast(u64)c) - (cast(u64)'0');
		} else if (isHexDigit(c)) {
			lowerC := asciiToLower(c);
			digit = 10 + ((cast(u64)lowerC) - (cast(u64)'a'));
		}
		if (digit >= cast(u64)base) {
			throw new ConvException(format("Invalid digit %s for base %s.", digit, base));
		}
		integer += digit * cast(u64)column;
		column *= cast(u64) base;
	}
	return integer;
}

fn toLong(s : const(char)[], base : i32 = 10) i64
{
	i64 multiply = 1;
	if (s.length > 0 && s[0] == '-') {
		s = s[1 .. $];
		multiply = -1;
	}
	v := cast(i64)toUlong(s, base);
	return v * multiply;
}

fn toInt(s : const(char)[], base : i32 = 10) i32
{
	v := toLong(s, base);
	return cast(i32)v;
}

fn toUint(s : const(char)[], base : i32 = 10) u32
{
	v := toUlong(s, base);
	return cast(u32)v;
}

fn toFloat(s : string) f32
{
	cstr : const(char)* = toStringz(s);
	return strtof(cstr, null);
}

fn toDouble(s : string) f64
{
	cstr : const(char)* = toStringz(s);
	return strtod(cstr, null);
}

fn toString(b : u8) const(char)[]
{
	return toStringUnsigned(b, 3);
}

fn toString(b : i8) const(char)[]
{
	return toStringSigned(b, 4);
}

fn toString(s : u16) const(char)[]
{
	return toStringUnsigned(s, 5);
}

fn toString(s : i16) const(char)[]
{
	return toStringSigned(s, 6);
}

fn toString(i : u32) const(char)[]
{
	return toStringUnsigned(i, 10);
}

fn toString(i : i32) const(char)[]
{
	return toStringSigned(i, 11);
}

fn toString(l : u64) const(char)[]
{
	return toStringUnsigned(l, 19);
}

fn toString(l : i64) const(char)[]
{
	return toStringSigned(l, 20);
}

fn toString(f : f32) const(char)[]
{
	buf : char[1024];
	retval : i32 = snprintf(buf.ptr, buf.length, "%f", f);

	if (retval < 0) {
		throw new ConvException("couldn't convert float to string.");
	}
	return new string(buf[0 .. cast(size_t)retval]);
}

fn toString(d : f64) const(char)[]
{
	buf : char[1024];
	retval : i32 = snprintf(buf.ptr, buf.length, "%f", d);

	if (retval < 0) {
		throw new ConvException("couldn't convert double to string.");
	}
	return new string(buf[0 .. cast(size_t)retval]);
}

fn toString(p : void*) const(char)[]
{
	u := cast(size_t) p;
	return "0x" ~ toStringHex(u);
}

fn toString(b : bool) const(char)[]
{
	return b ? "true" : "false";
}

fn charToString(c : dchar) const(char)[]
{
	if ((cast(u32) c) >= 255) {
		throw new Error("charToString: non ASCII dchars unimplemented.");
	}
	buf := new char[](1);
	buf[0] = cast(char) c;
	return cast(const(char)[]) buf;
}

// maxLength == maximum length of output string, including '-' for signed integers.

private fn toStringUnsigned(i : u64, maxLength : size_t) const(char)[]
{
	index : size_t = 0u;
	buf := new char[](maxLength);

	inLoop := true;
	while (inLoop) {
		remainder : u64 = i % 10;
		c := cast(char)(cast(ulong)'0' + remainder);
		i = i / 10;
		buf[index++] = c;
		inLoop = i != 0;
	}
	buf = buf[0 .. index];

	outbuf := new char[](maxLength);
	bindex : size_t = index;
	oindex : size_t = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}

	return outbuf[0 .. oindex];
}

private fn toStringSigned(i : i64, maxLength : size_t) const(char)[]
{
	index : size_t = 0u;
	buf := new char[](maxLength);
	negative : bool = i < 0;
	if (negative) {
		i = i * -1;
	}
	
	inLoop := true;
	while (inLoop) {
		remainder : i64 = i % 10;
		c := cast(char)(cast(i64)'0' + remainder);
		i = i / 10;
		buf[index++] = c;
		inLoop = i != 0;
	}
	if (negative) {
		buf[index++] = '-';
	}
	buf = buf[0 .. index];

	outbuf := new char[](maxLength);
	bindex : size_t = index;
	oindex : size_t = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}

	return outbuf[0 .. oindex];
}

/// Returns an upper case hex string from the given unsigned long.
fn toStringHex(i : u64) const(char)[]
{
	buf := new char[](0);

	inLoop := true;
	while (inLoop) {
		remainder : u64 = i % 16;
		c : char = HEX_DIGITS[remainder];
		i = i / 16;
		buf ~= c;
		inLoop = i != 0;
	}

	outbuf := new char[](buf.length);
	bindex : size_t = buf.length;
	oindex : size_t = 0u;
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
fn toStringz(s : const(char)[]) const(char)*
{
	cstr := new char[](s.length + 1);
	cstr[0 .. $-1] = s[0 .. $];
	cstr[$ - 1] = '\0';
	return cast(const(char)*) cstr.ptr;
}

/**
 * Given a nul terminated string s, return a Volt string.
 */
fn toString(s : scope const(char)*) string
{
	if (s is null) {
		return null;
	}
	len := strlen(s);
	if (len == 0) {
		return null;
	}

	str := new char[](len);
	str[] = s[0 .. str.length];
	return cast(string) str;
}

fn toString(s : const(char)*) string
{
	if (s is null) {
		return null;
	}
	len := strlen(s);
	if (len == 0) {
		return null;
	}

	str := new char[](len);
	str[] = s[0 .. str.length];
	return cast(string) str;
}
