// Copyright 2013-2014, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
//! Functions dealing with converting strings to integers, integers to strings, integers to different types of integers, and so on.
module watt.conv;

import core.exception;
import core.rt.format;

import ascii = watt.text.ascii;
import watt.text.format: format;
import watt.text.utf: encode;
import watt.text.sink: SinkArg, StringSink;
import watt.text.string : StrArg;


/*!
 * Thrown when a conversion fails.
 */
class ConvException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

/*!
 * Get the lowercase representation of a `string`.
 *
 * If a character in `s` can be represented as a lower case letter
 * of some description, it is replaced with such. Otherwise, it remains
 * intact.  
 * ### Examples
 *     toLower("APPLE");  // returns "apple"
 *     toLower("BA(NA)NA 32%");  // returns "ba(na)na 32%"
 */
fn toLower(s: StrArg) string
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
		default: encode(dst.sink, ascii.toLower(c)); break;
		}
	}
	return dst.toString();
}

/*!
 * Get the uppercase representation of a `string`.
 *
 * If a character in `s` can be represented with an uppercase letter,
 * that letter is replaced with such. Otherwise, the character remains
 * intact.  
 * ### Examples
 *      toUpper("hellO THERE 32");  // returns "HELLO THERE 32"
 */
fn toUpper(s: StrArg) string
{
	ns := new char[](s.length);
	for (i: size_t = 0; i < s.length; i++) {
		ns[i] = cast(char) ascii.toUpper(s[i]);
	}
	return new string(ns);
}

/*!
 * Parse `s` as an integer, and return it as a `u64`.
 * @Throws `ConvException` if `s` could not be converted.
 * @param s The string to convert.
 * @param base The base of `s`. 10 is the default.
 */
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
		if (base != 16 && !ascii.isDigit(c)) {
			throw new ConvException(format("Found non digit %s.", c));
		} else if (base == 16 && !ascii.isHexDigit(c)) {
			throw new ConvException(format("Found non hex digit %s.", c));
		}
		digit: u64;
		if (ascii.isDigit(c)) {
			digit = (cast(u64)c) - (cast(u64)'0');
		} else if (ascii.isHexDigit(c)) {
			lowerC := ascii.toLower(c);
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

/*!
 * Parse `s` as an integer, and return it as an `i64`.
 * @Throws `ConvException` if `s` could not be converted.
 * @param s The string to convert.
 * @param base The base of `s`. 10 is the default.
 */
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

/*!
 * Parse `s` as an integer, and return it as an `i32`.
 * @Throws `ConvException` if `s` could not be converted.
 * @param s The string to convert.
 * @param base The base of `s`. 10 is the default.
 */
fn toInt(s: const(char)[], base: i32 = 10) i32
{
	v := toLong(s, base);
	return cast(i32)v;
}

/*!
 * Parse `s` as an integer, and return it as a `u32`.
 * @Throws `ConvException` if `s` could not be converted.
 * @param s The string to convert.
 * @param base The base of `s`. 10 is the default.
 */
fn toUint(s: const(char)[], base: i32 = 10) u32
{
	v := toUlong(s, base);
	return cast(u32)v;
}

/*!
 * Get a string from a given `u8`.
 * ### Examples
 *     toString(32);  // returns "32"
 */
fn toString(val: u8) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an `i8` as a string.
fn toString(val: i8) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a `u16` as a string.
fn toString(val: u16) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an `i16` as a string.
fn toString(val: i16) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a `u32` as a string.
fn toString(val: u32) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an `i32` as a string.
fn toString(val: i32) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return a `u64` as a string.
fn toString(val: u64) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_u64(s, val);
	return ret;
}

//! Return an `i64` as a string.
fn toString(val: i64) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_i64(s, val);
	return ret;
}

//! Return an `f32` as a string.
fn toString(f: f32) string
{
	s: StringSink;
	vrt_format_f32(s.sink, f);
	ret := s.toString();
	if (ret is null) {
		throw new ConvException("couldn't convert float to string.");
	}
	return ret;
}

//! Return an `f64` as a string.
fn toString(f: f64) string
{
	s: StringSink;
	vrt_format_f64(s.sink, f);
	ret := s.toString();
	if (ret is null) {
		throw new ConvException("couldn't convert double to string.");
	}
	return ret;
}

//! Return a pointer as a string.
fn toString(p: void*) string
{
	u := cast(size_t) p;
	version (V_P64) {
		return format("%016s", toStringHex(u));
	} else {
		return format("%08s", toStringHex(u));
	}
}

//! Return a `bool` as "true" or "false".
fn toString(b: bool) string
{
	return b ? "true": "false";
}

//! Returns an upper case hex string from the given unsigned long.
fn toStringHex(val: u64) string
{
	ret: string;
	fn s(a: SinkArg) {
		ret = new string(a);
	}
	vrt_format_hex(s, val, 0);
	return ret;
}

//! Given a `u8`, return a binary string.
fn toStringBinary(val: u8) string
{
	str := new char[](8);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x80) != 0;
		s = msb ? '1' : '0';
	}
	return cast(string)str;
}

//! Given a `u16`, return a binary string.
fn toStringBinary(val: u16) string
{
	str := new char[](16);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x8000) != 0;
		s = msb ? '1' : '0';
	}
	return cast(string)str;
}

//! Given a `u32`, return a binary string.
fn toStringBinary(val: u32) string
{
	str := new char[](32);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x80000000UL) != 0;
		s = msb ? '1' : '0';
	}
	return cast(string)str;
}

//! Given a `u64`, return a binary string.
fn toStringBinary(val: u64) string
{
	str := new char[](64);
	foreach (i, ref s: char; str) {
		msb := ((val << i) & 0x8000000000000000UL) != 0;
		s = msb ? '1' : '0';
	}
	return cast(string)str;
}

//! Given an `i8`, return a binary string.
fn toStringBinary(val: i8) string
{
	return toStringBinary(cast(u8)val);
}

//! Given an `i16`, return a binary string.
fn toStringBinary(val: i16) string
{
	return toStringBinary(cast(u16)val);
}

//! Given an `i32`, return a binary string.
fn toStringBinary(val: i32) string
{
	return toStringBinary(cast(u32)val);
}

//! Given an `i64`, return a binary string.
fn toStringBinary(val: i64) string
{
	return toStringBinary(cast(u64)val);
}

/*!
 * Given a Volt string s, return a pointer to a null terminated string.
 *
 * This is for interfacing with C libraries.
 */
fn toStringz(s: SinkArg) const(char)*
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
	 * Given a null terminated string s, return a Volt string.
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

	//! Return a string as an `f32`.
	fn toFloat(s: string) f32
	{
		cstr: const(char)* = toStringz(s);
		return strtof(cstr, null);
	}

	//! Return a string as an `f64`.
	fn toDouble(s: string) f64
	{
		cstr: const(char)* = toStringz(s);
		return strtod(cstr, null);
	}

}
