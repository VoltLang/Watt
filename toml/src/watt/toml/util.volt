// Copyright 2017, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
module watt.toml.util;

import rt = core.exception;
import conv = watt.conv;
import sink = watt.text.sink;
import source = watt.text.source;
import ascii = watt.text.ascii;
import utf = watt.text.utf;

/*!
 * Thrown on input error.
 */
class TomlException : rt.Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

// If `p.src` is at a `c`, eat it. Otherwise, generate an error.
fn match(ref src: source.SimpleSource, c: dchar)
{
	if (src.front != c) {
		throw new TomlException(new "Error parsing TOML: expected '${src.front}', got '${c}'.");
	}
	src.popFront();
}

//! If `p.src` is at `c`, eat it and return true. Otherwise, return false.
fn matchIf(ref src: source.SimpleSource, c: dchar) bool
{
	if (src.front == c) {
		src.popFront();
		return true;
	}
	return false;
}

fn atTripleString(ref src: source.SimpleSource) bool
{
	empty := false;
	return (src.front == '"' || src.front == '\'') &&
		(src.following == '"' || src.front == '\'') &&
		(src.lookahead(2, out empty) == '"' || src.lookahead(2, out empty) == '\'');
}

fn skipIfNewline(ref src: source.SimpleSource)
{
	if (src.following == '\n') {
		matchIf(ref src, '\r');
	}
	matchIf(ref src, '\n');
}

fn parseMultilineString(ref src: source.SimpleSource) string
{
	rawstr := src.front == '\'';
	src.popFrontN(3);
	skipIfNewline(ref src);
	stringStart := src.save();
	while (!src.eof && !atTripleString(ref src)) {
		src.popFront();
	}
	stringValue := src.sliceFrom(stringStart);
	if (!rawstr) {
		stringValue = escapeString(unescaped:stringValue, multiline:true);
	}
	src.popFrontN(3);
	return stringValue;
}

fn parseString(ref src: source.SimpleSource) string
{
	if (atTripleString(ref src)) {
		return parseMultilineString(ref src);
	}
	terminator := src.front;
	rawstr := terminator == '\'';
	src.popFront();
	stringStart := src.save();
	while (!src.eof && src.front != terminator) {
		if (!rawstr && src.front == '\\' && src.following == '\\') {
			// this is so `"\\"` works
			src.popFront();
		} else if (!rawstr && src.front == '\\' && src.following == terminator) {
			src.popFront();
		}
		if (src.front <= 0x1F) {
			throw new TomlException("Error parsing TOML: control character in simple string.");
		}
		src.popFront();
	}
	stringValue := src.sliceFrom(stringStart);
	if (!rawstr) {
		stringValue = escapeString(unescaped:stringValue, multiline:false);
	}
	match(ref src, terminator);
	return stringValue;
}

fn escapeString(unescaped: string, multiline: bool) string
{
	ss: sink.StringSink;
	escaping := false;
	whiteskipping := false;
	unicoding: size_t;
	hexchars: char[];

	fn doUnicode(c: dchar)
	{
		if (hexchars.length == unicoding) {
			i: u32;
			try {
				i = cast(u32)conv.toInt(hexchars, 16);
			} catch (conv.ConvException) {
				throw new TomlException("Error parsing TOML: expected unicode codepoint specification.");
			}

			if (hexchars.length == 4) {
				utf.encode(ss.sink, i);
			} else if (hexchars.length == 8) {
				utf.encode(ss.sink, cast(u16)i);
			} else {
				throw new TomlException("Error parsing TOML: expected unicode codepoint specification.");
			}
			unicoding = 0;
		} else { 
			throw new TomlException("Error parsing TOML: expected unicode codepoint specification.");
		}
	}

	foreach (c: dchar; unescaped) {
		if (whiteskipping) {
			if (ascii.isWhite(c)) {
				continue;
			}
			whiteskipping = false;
		}
		// \uXXXX
		if (unicoding) {
			if (!ascii.isHexDigit(c)) {
				doUnicode(c);
			}
			if (unicoding) {
				utf.encode(ref hexchars, c);
			}
			if (unicoding) {
				continue;
			}
		}

		if (!escaping && c == '\\') {
			escaping = true;
			continue;
		}
		if (!escaping) {
			ss.sink(utf.encode(c));
			continue;
		}
		switch (c) {
		case '\"': ss.sink("\""); break;
		case '\\': ss.sink("\\"); break;
		case 't': ss.sink("\t"); break;
		case 'b': ss.sink("\b"); break;
		case 'n': ss.sink("\n"); break;
		case 'f': ss.sink("\f"); break;
		case 'r': ss.sink("\r"); break;
		case 'u': unicoding = 4; break;
		case 'U': unicoding = 8; break;
		default:
			if (multiline && ascii.isWhite(c)) {
				whiteskipping = true;
			} else {
				throw new TomlException(new "Error parsing TOML: bad escape character '${c}'.");
			}
		}
		escaping = false;
	}
	if (unicoding) {
		doUnicode(' ');
	}
	if (escaping) {
		throw new TomlException("Error parsing TOML: expected escape character, got end of string.");
	}
	return ss.toString();
}
