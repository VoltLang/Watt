// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, David Herberth.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.json.util;

import core.stdc.stdlib : strtod;
import watt.text.utf : encode;
import watt.text.ascii : isDigit, isHexDigit, HEX_DIGITS;
import watt.conv : toLong, toUlong, toLower;

/**
 * Base Exception for the whole json module.
 */
class JSONException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

/**
 * Exception thrown when an error occurs during parsing.
 */
class ParseException : JSONException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

/**
 * Returns true if data contains a non-digit, character.
 * If signed is false, '-' will make this function return false.
 */
bool canBeInteger(const(char)[] data, bool signed)
{
	for (size_t i = 0; i < data.length; ++i) {
		if (!isDigit(data[i]) && (!signed || data[i] != '-')) {
			return false;
		}
	}
	return true;
}

/**
 * Parse a ulong from a JSON number string.
 * Returns true if a double was parsed, false otherwise.
 */
bool parseUlong(const(char)[] data, out ulong l)
{
	if (!canBeInteger(data, false)) {
		return false;
	}
	l = toUlong(data);
	return true;
}

/**
 * Parse a long from a JSON number string.
 * Returns true if a double was parsed, false otherwise.
 */
bool parseLong(const(char)[] data, out long l)
{
	if (!canBeInteger(data, true)) {
		return false;
	}
	l = toLong(data);
	return true;
}

/**
 * Parse a double from a JSON number string.
 *
 * Returns true if a double was parsed, false otherwise.
 */
bool parseDouble(const(char)[] data, out double d)
{
	char[] buffer;
	return parseDouble(data, out d, ref buffer);
}

/**
 * Parse a double from a JSON number string, using a pre allocated buffer,
 * resizing it if needed.
 *
 * Returns true if a double was parsed, false otherwise.
 */
bool parseDouble(const(char)[] data, out double d, ref char[] buffer)
{
	const(void)* ptr = cast(const(void)*)data.ptr;
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

bool parseBool(const(char)[] data)
{
	return toLower(data) == "true";
}

/**
 * Unescape a JSON string and return it.
 */
const(char)[] unescapeString(const(char)[] str)
{
	char[] buffer;
	return unescapeString(str, ref buffer);
}

/**
 * Unescape a JSON string and return it, using a pre allocated buffer and
 * resizing it if needed.
 */
const(char)[] unescapeString(const(char)[] str, ref char[] buffer)
{
	bool needsEscape = false;
	bool escaping = false;
	char[4] hexBuffer;
	size_t bufferIndex;
	size_t toCopyIndex;
	size_t i;

	void doUnescape(const(char)[] unescaped)
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
			auto diff = toCopyIndex - bufferIndex;
			buffer[bufferIndex..toCopyIndex] = str[i-diff-1..i-1];
			bufferIndex = toCopyIndex;
		}

		// the string can only get shorter, no need to resize
		auto newLen = bufferIndex + unescaped.length;
		buffer[bufferIndex..newLen] = unescaped[];
		bufferIndex = newLen;
		toCopyIndex = bufferIndex;
	}

	for (i = 0; i < str.length; i++) {
		char c = str[i];

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
		auto diff = toCopyIndex - bufferIndex;
		buffer[bufferIndex..toCopyIndex] = str[i-diff..i];
		return buffer[0..toCopyIndex];
	}
	// no escapes happened, we never allocated memory.
	return str;
}

private void simpleCharToHex(char c, char* buffer)
{
    buffer[0] = HEX_DIGITS[c >> 4];
    buffer[1] = HEX_DIGITS[c & 0x0F];
}

/**
 * Escapes a JSON string and returns it.
 */
const(char)[] escapeString(const(char)[] str)
{
	char[] buffer;
	return escapeString(str, ref buffer);
}

/**
 * Escapes a JSON string and returns it, using a pre allocated buffer and
 * resizing it if needed.
 */
const(char)[] escapeString(const(char)[] str, ref char[] buffer)
{
	bool needsEscape = false;
	size_t bufferIndex;
	size_t toCopyIndex;
	size_t i = 0;
	char[6] hexBuffer = ['\\', 'u', '0', '0', '0', '0'];

	void doEscape(const(char)[] escape)
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

		auto diff = toCopyIndex - bufferIndex;
		auto newLen = bufferIndex + escape.length + diff;
		if (buffer.length < newLen) { // resize buffer if needed.
			auto tmp = new char[](newLen + 32);
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
		char c = str[i];

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
		auto diff = toCopyIndex - bufferIndex;
		if (buffer.length < bufferIndex + toCopyIndex) {
			auto tmp = new char[](bufferIndex + toCopyIndex);
			tmp[0..buffer.length] = buffer[];
			buffer = tmp;
		}
		buffer[bufferIndex..toCopyIndex] = str[i-diff..i];
		return buffer[0..toCopyIndex];
	}
	// no escapes happened, we never allocated memory.
	return str;
}
