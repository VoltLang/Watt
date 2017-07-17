// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Functions for converting one thing into another.
module watt.conv;

import core.exception;
import core.rt.format;

import watt.text.ascii: isDigit, isHexDigit, asciiToLower = toLower, asciiToUpper = toUpper, HEX_DIGITS;
import watt.text.format: format;
import watt.text.utf: encode;
import watt.text.sink: StringSink;


//! Thrown if a conversion couldn't be performed.
class ConvException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

//! Return @p s as lowercase, where possible.
fn toLower(s: string) string
{
	dst: StringSink;
	// @TODO extend to support all lowercase.
	// https://www-01.ibm.com/support/knowledgecenter/ssw_ibm_i_71/nls/rbagslowtoupmaptable.htm
	foreach (c: dchar; s) {
		switch (c) {
		case 'Α': dst.sink("α"); break;
		case 'Γ': dst.sink("γ"); break;
		case 'Ω': dst.sink("ω"); break;
		case 'О': dst.sink("о"); break;
		case 'Л': dst.sink("л"); break;
		case 'П': dst.sink("п"); break;
		case 'Й': dst.sink("й"); break;
		default: dst.sink(encode(asciiToLower(c))); break;
		}
	}
	return dst.toString();
}

//! Return @p s as uppercase, where possible.
fn toUpper(s: string) string
{
	ns := new char[](s.length);
	for (i: size_t = 0; i < s.length; i++) {
		ns[i] = cast(char) asciiToUpper(s[i]);
	}
	return cast(string) ns;
}

//! Return a string as u64.
fn toUlong(s: const(char)[], base: i32 = 10) u64
{
	if (base > 10 || base <= 0) {
		if (base != 16) {
			throw new ConvException(format("Don't know how to handle base %s.", base));
		}
	}
	integer: u64;
	column: u64 = 1;
	for (i := s.length; i > 0; i--) {
		c: char = s[i - 1];
		if (base != 16 && !isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		digit: u64;
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

//! Return a string as an i64.
fn toLong(s: const(char)[], base: i32 = 10) i64
{
	multiply: i64 = 1;
	if (s.length > 0 && s[0] == '-') {
		s = s[1 .. $];
		multiply = -1;
	}
	v := cast(i64)toUlong(s, base);
	return v * multiply;
}

//! Return a string as an i32.
fn toInt(s: const(char)[], base: i32 = 10) i32
{
	v := toLong(s, base);
	return cast(i32)v;
}

//! Return a string as a u32.
fn toUint(s: const(char)[], base: i32 = 10) u32
{
	v := toUlong(s, base);
	return cast(u32)v;
}

//! Return a u8 as a string.
fn toString(val: u8) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an i8 as a string.
fn toString(val: i8) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a u16 as a string.
fn toString(val: u16) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an i16 as a string.
fn toString(val: i16) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a u32 as a string.
fn toString(val: u32) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an i32 as a string.
fn toString(val: i32) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a u64 as a string.
fn toString(val: u64) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an i64 as a string.
fn toString(val: i64) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return an f32 as a string.
fn toString(f: f32) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_f32(s, f);
	if (ret is null) {
		throw new ConvException("couldn't convert float to string.");
	}
	return ret;
}

//! Return an f64 as a string.
fn toString(f: f64) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_f64(s, f);
	if (ret is null) {
		throw new ConvException("couldn't convert double to string.");
	}
	return ret;
}

//! Return a pointer as a string.
fn toString(p: void*) const(char)[]
{
	u := cast(size_t) p;
	return format("%s", toStringHex(u));
}

//! Return a boolean as "true" or "false".
fn toString(b: bool) const(char)[]
{
	return b ? "true": "false";
}

//! Return a dchar as a string.
fn charToString(c: dchar) const(char)[]
{
	if ((cast(u32) c) >= 255) {
		throw new Error("charToString: non ASCII dchars unimplemented.");
	}
	buf := new char[](1);
	buf[0] = cast(char) c;
	return cast(const(char)[]) buf;
}

//! Returns an upper case hex string from the given unsigned long.
fn toStringHex(val: u64) const(char)[]
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_hex(s, val, 0);
	return ret;
}

//! Given a u8, return a binary string.
fn toStringBinary(val: u8) const(char)[]
{
	str := new char[](8);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x80) != 0;
		s = msb ? '1' : '0';
	}
	return cast(const(char)[])str;
}

//! Given a u16, return a binary string.
fn toStringBinary(val: u16) const(char)[]
{
	str := new char[](16);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x8000) != 0;
		s = msb ? '1' : '0';
	}
	return cast(const(char)[])str;
}

//! Given a u32, return a binary string.
fn toStringBinary(val: u32) const(char)[]
{
	str := new char[](32);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x80000000UL) != 0;
		s = msb ? '1' : '0';
	}
	return cast(const(char)[])str;
}

//! Given a u64, return a binary string.
fn toStringBinary(val: u64) const(char)[]
{
	str := new char[](64);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x8000000000000000UL) != 0;
		s = msb ? '1' : '0';
	}
	return cast(const(char)[])str;
}

//! Given an i8, return a binary string.
fn toStringBinary(val: i8) const(char)[]
{
	return toStringBinary(cast(u8)val);
}

//! Given an i16, return a binary string.
fn toStringBinary(val: i16) const(char)[]
{
	return toStringBinary(cast(u16)val);
}

//! Given an i32, return a binary string.
fn toStringBinary(val: i32) const(char)[]
{
	return toStringBinary(cast(u32)val);
}

//! Given an i64, return a binary string.
fn toStringBinary(val: i64) const(char)[]
{
	return toStringBinary(cast(u64)val);
}

/*!
 * Given a Volt string s, return a pointer to a nul terminated string.
 */
fn toStringz(s: const(char)[]) const(char)*
{
	cstr := new char[](s.length + 1);
	cstr[0 .. $-1] = s[0 .. $];
	cstr[$ - 1] = '\0';
	return cast(const(char)*) cstr.ptr;
}

version (CRuntime_All) {

	import core.c.string : strlen;
	import core.c.stdlib : strtof, strtod;

	/*!
	 * Given a nul terminated string s, return a Volt string.
	 */
	fn toString(s: scope const(char)*) string
	{
		if (s is null) {
			return null;
		}

		len := strlen(cast(const(char)*)s);

		if (len == 0) {
			return null;
		}

		str := new char[](len);
		str[] = s[0 .. str.length];
		return cast(string) str;
	}

	//! Return a string as an f32.
	fn toFloat(s: string) f32
	{
		cstr: const(char)* = toStringz(s);
		return strtof(cstr, null);
	}

	//! Return a string as an f64.
	fn toDouble(s: string) f64
	{
		cstr: const(char)* = toStringz(s);
		return strtod(cstr, null);
	}

}
