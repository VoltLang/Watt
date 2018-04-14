// Copyright 2015, Bernard Helyer.
// Copyright 2015, David Herberth.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Useful functions when dealing with [JSON](http://json.org/).
 *
 * The @ref watt.json.sax parser doesn't process any of the output
 * it gives. Use these functions to get data from what it gives you.
 */
module watt.json.util;

import core.exception;
import core.c.stdlib: strtod;
import watt.text.utf: encode;
import watt.text.ascii: isDigit, isHexDigit, HEX_DIGITS;
import watt.conv: toLong, toUlong, toLower;


/*!
 * Base `Exception` for the whole json package.
 */
class JSONException : Exception
{
	this(msg: string, location: string = __LOCATION__)
	{
		super(msg, location);
	}
}

/*!
 * `Exception` thrown when an error occurs during parsing.
 */
class ParseException : JSONException
{
	this(msg: string, location: string = __LOCATION__)
	{
		super(msg, location);
	}
}

/*!
 * @Param signed If `false`, '-' will make this function return `false`.
 * @Returns `true` if `data` contains a non-digit character.
 */
fn canBeInteger(data: const(char)[], signed: bool) bool
{
	for (i: size_t = 0; i < data.length; ++i) {
		if (!isDigit(data[i]) && (!signed || data[i] != '-')) {
			return false;
		}
	}
	return true;
}

/*!
 * Parse a `u64` from a JSON number string.
 *
 * @Returns `true` if a double was parsed.
 */
fn parseUlong(data: const(char)[], out l: u64) bool
{
	if (!canBeInteger(data, false)) {
		return false;
	}
	l = toUlong(data);
	return true;
}

/*!
 * Parse an `i64` from a JSON number string.
 * Returns `true` if a double was parsed.
 */
fn parseLong(data: const(char)[], out l: i64) bool
{
	if (!canBeInteger(data, true)) {
		return false;
	}
	l = toLong(data);
	return true;
}

/*!
 * Parse a double from a JSON number string.
 *
 * Returns `true` if a double was parsed, `false` otherwise.
 */
fn parseDouble(data: const(char)[], out d: f64) bool
{
	buffer: char[];
	return parseDouble(data, out d, ref buffer);
}

/*!
 * Parse a double from a JSON number string, using a pre allocated buffer,
 * resizing it if needed.
 *
 * @Returns `true` if a double was parsed.
 */
fn parseDouble(data: const(char)[], out d: f64, ref buffer: char[]) bool
{
	// @TODO just call toDouble with data?
	ptr := cast(const(void)*)data.ptr;
	if (data[$-1] != '\0') {
		if (buffer.length <= data.length) {
			buffer = new char[](data.length + 1);
		}
		buffer[0 .. data.length] = data[];
		buffer[data.length] = '\0';
		ptr = cast(const(void)*)buffer.ptr;
	}
	d = strtod(cast(const(char)*)ptr, null);
	return true;
}

/*!
 * @Returns the boolean value of a string.
 */
fn parseBool(data: const(char)[]) bool
{
	return toLower(data) == "true";
}

/*!
 * Unescape a JSON string and return it.
 * @{
 */
fn unescapeString(str: const(char)[]) const(char)[]
{
	buffer: char[];
	return unescapeString(str, ref buffer);
}

fn unescapeString(str: const(u8)[]) const(char)[]
{
	buffer: char[];
	return unescapeString(cast(const(char)[])str, ref buffer);
}
//! @}

/*!
 * Unescape a JSON string and return it, using a pre allocated buffer and
 * resizing it if needed.
 */
fn unescapeString(str: const(char)[], ref buffer: char[]) const(char)[]
{
	needsEscape := false;
	escaping := false;
	hexBuffer: char[4];
	bufferIndex: size_t;
	toCopyIndex: size_t;
	i: size_t;

	fn doUnescape(unescaped: const(char)[])
	{
		if (!needsEscape) {
			if (buffer.length < str.length) {
				buffer = new char[](str.length);
			}
			assert(i >= 1);
			bufferIndex = i-1;
			buffer[0..bufferIndex] = str[0..bufferIndex];
			needsEscape = true;
		} else {
			diff := toCopyIndex - bufferIndex;
			buffer[bufferIndex..toCopyIndex] = str[i-diff-1..i-1];
			bufferIndex = toCopyIndex;
		}

		// the string can only get shorter, no need to resize
		newLen := bufferIndex + unescaped.length;
		buffer[bufferIndex..newLen] = unescaped[];
		bufferIndex = newLen;
		toCopyIndex = bufferIndex;
	}

	for (i = 0; i < str.length; i++) {
		c: char = str[i];

		if (escaping) {
			switch (c) {
				case '"':
					doUnescape("\"");
					break;
				case '\\':
					doUnescape("\\");
					break;
				case '/':
					doUnescape("/");
					break;
				case 'b':
					doUnescape("\b");
					break;
				case 'f':
					doUnescape("\f");
					break;
				case 'n':
					doUnescape("\n");
					break;
				case 'r':
					doUnescape("\r");
					break;
				case 't':
					doUnescape("\t");
					break;
				case 'u':
					if (i+4 >= str.length) {
						throw new ParseException("Not enough hexadecimal digits in string escape.");
					}
					hexBuffer[0] = str[++i];
					hexBuffer[1] = str[++i];
					hexBuffer[2] = str[++i];
					hexBuffer[3] = str[++i];
					doUnescape(encode(cast(dchar)toUlong(hexBuffer, 16)));
					break;
				default:
					throw new ParseException("Invalid string escape.");
			}
			escaping = false;
		} else if (c == '\\') {
			escaping = true;
		} else {
			++toCopyIndex;
		}
	}

	if (needsEscape) {
		diff := toCopyIndex - bufferIndex;
		buffer[bufferIndex..toCopyIndex] = str[i-diff..i];
		return buffer[0..toCopyIndex];
	}
	// no escapes happened, we never allocated memory.
	return str;
}

private fn simpleCharToHex(c: char, buffer: char*)
{
    buffer[0] = HEX_DIGITS[c >> 4];
    buffer[1] = HEX_DIGITS[c & 0x0F];
}

/*!
 * Escape a JSON string and return it.
 */
fn escapeString(str: const(char)[]) const(char)[]
{
	buffer: char[];
	return escapeString(str, ref buffer);
}

/*!
 * Escape a JSON string and return it, using a pre allocated buffer and
 * resizing it if needed.
 */
fn escapeString(str: const(char)[], ref buffer: char[]) const(char)[]
{
	needsEscape := false;
	bufferIndex: size_t;
	toCopyIndex: size_t;
	i: size_t = 0;
	hexBuffer: char[6] = ['\\', 'u', '0', '0', '0', '0'];

	fn doEscape(escape: const(char)[])
	{
		// is it the first encountered escape?
		if (!needsEscape) {
			if (buffer.length < str.length) {
				buffer = new char[](str.length + 32);
			}
			buffer[0..i] = str[0..i];
			bufferIndex = i;
			toCopyIndex = bufferIndex;
			needsEscape = true;
		}

		diff := toCopyIndex - bufferIndex;
		newLen := bufferIndex + escape.length + diff;
		if (buffer.length < newLen) { // resize buffer if needed.
			tmp := new char[](newLen + 32);
			tmp[0..buffer.length] = buffer[];
			buffer = tmp;
		}
		buffer[bufferIndex..toCopyIndex] = str[i-diff..i];
		bufferIndex = toCopyIndex;

		buffer[bufferIndex..newLen] = escape[];
		bufferIndex = newLen;
		toCopyIndex = bufferIndex;
	}

	for (i = 0; i < str.length; ++i) {
		c: char = str[i];

		switch (c) {
			case '"':
				doEscape("\\\"");
				break;
			case '\\':
				doEscape("\\\\");
				break;
			case '/':
				doEscape("\\/");
				break;
			case '\b':
				doEscape("\\b");
				break;
			case '\f':
				doEscape("\\f");
				break;
			case '\n':
				doEscape("\\n");
				break;
			case '\r':
				doEscape("\\r");
				break;
			case '\t':
				doEscape("\\t");
				break;
			// case '\u':
			default:
				if (c < 32) { // non-printable
					simpleCharToHex(c, &hexBuffer[4]);
					doEscape(hexBuffer);
				} else {
					++toCopyIndex;
				}
				break;
		}
	}

	if (needsEscape) {
		diff := toCopyIndex - bufferIndex;
		if (buffer.length < bufferIndex + toCopyIndex) {
			tmp := new char[](bufferIndex + toCopyIndex);
			tmp[0..buffer.length] = buffer[];
			buffer = tmp;
		}
		buffer[bufferIndex..toCopyIndex] = str[i-diff..i];
		return buffer[0..toCopyIndex];
	}
	// no escapes happened, we never allocated memory.
	return str;
}
