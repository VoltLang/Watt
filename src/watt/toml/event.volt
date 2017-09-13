// Copyright © 2017, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Event driven [TOML](https://github.com/toml-lang/toml) parser, a la SAX.
module watt.toml.event;

import source = watt.text.source;
import sink = watt.text.sink;
import ascii = watt.text.ascii;
import conv = watt.conv;
import utf = watt.text.utf;

import util = watt.toml.util;

/*!
 * Given a TOML string input, call the appropriate methods on the given `EventSink`.
 */
fn runEventSink(txt: string, esink: EventSink)
{
	p: Parser;
	p.src.source = txt;
	p.esink = esink;

	esink.start();
	loop(ref p);
	esink.end();
}

/*!
 * Interface for toml string consumers.
 *
 * Implement this class, and pass an instance of your
 * implementation to the @ref watt.toml.event.parse function.
 */
interface EventSink
{
	//! Signals the start of content.
	fn start();
	//! Signals the end of content.
	fn end();

	//! Signals the start of a comment. Comment value is sent via `stringContent`.
	fn commentStart();
	//! Signals the end of a comment.
	fn commentEnd();

	//! Signals the start of a key/value pair.
	fn keyValueStart(key: string);
	//! Signals the end of a key/value pair.
	fn keyValueEnd(key: string);

	//! Signals the start of a table.
	fn tableStart(name: string);
	//! Signals the end of a table.
	fn tableEnd(name: string);

	//! Signals a table array.
	fn tableArray(name: string);

	//! Signals an inline table value start.
	fn inlineTableStart();
	//! Signals the end of an inline table value.
	fn inlineTableEnd();

	//! Signals the start of an array.
	fn arrayStart();
	//! Signals the end of an array.
	fn arrayEnd();

	//! Regular text content, used by multiple events.
	fn stringContent(str: string);
	//! Signed integer content.
	fn integerContent(i: i64);
	//! Boolean content.
	fn boolContent(b: bool);
	//! Floating point content.
	fn floatContent(n: f64);
}

//! A class that implements all the methods of `EventSink` by doing nothing.
class NullEventSink : EventSink
{
	override fn start() {}
	override fn end() {}

	override fn commentStart() {}
	override fn commentEnd() {}

	override fn keyValueStart(key: string) {}
	override fn keyValueEnd(key: string) {}

	override fn tableStart(name: string) {}
	override fn tableEnd(name: string) {}

	override fn tableArray(name: string) {}

	override fn inlineTableStart() {}
	override fn inlineTableEnd() {}

	override fn arrayStart() {}
	override fn arrayEnd() {}

	override fn stringContent(str: string) {}
	override fn integerContent(i: i64) {}
	override fn boolContent(b: bool) {}
	override fn floatContent(n: f64) {}
}

private:

// Holds internal parse state.
struct Parser
{
	src: source.SimpleSource;
	esink: EventSink;
	lastTable: string;
}

// Process until we encounter an error, or EOF.
fn loop(ref p: Parser)
{
	while (!p.src.eof) {
		dispatch(ref p);
	}
	if (p.lastTable != "") {
		p.esink.tableEnd(p.lastTable);
	}
}

// Figure what component to parse, and send it to the right place.
fn dispatch(ref p: Parser)
{
	while (ascii.isWhite(p.src.front)) {
		p.src.popFront();
	}
	if (p.src.eof) {
		return;
	}
	if (p.src.front == '#') {
		parseComment(ref p);
		return;
	}
	if (p.src.front == '[') {
		parseTable(ref p);
		return;
	}
	parseKeyValue(ref p);
	skipEndOfLine(ref p);
}

// Is this strictly what toml considers whitespace?
fn tomlWhitespace(c: dchar) bool
{
	return c == ' ' || c == '\t';
}

fn skipTomlWhitespace(ref p: Parser)
{
	while (!p.src.eof && tomlWhitespace(p.src.front)) {
		p.src.popFront();
	}
}

// skip toml whitespace, and newlines
fn skipWhitespace(ref p: Parser)
{
	while (!p.src.eof && (tomlWhitespace(p.src.front) ||
		   p.src.front == '\n' || p.src.front == '\r')) {
		p.src.popFront();
	}
}

fn skipEndOfLine(ref p: Parser)
{
	hitNewline := false;
	while (!p.src.eof && (tomlWhitespace(p.src.front) ||
		   p.src.front == '\n' || p.src.front == '\r')) {
		if (p.src.front == '\n') {
			hitNewline = true;
		}
		p.src.popFront();
		if (p.src.front == '\n' || p.src.front == '#') {
			hitNewline = true;
		}
	}
	if (!hitNewline && !p.src.eof) {
		throw new util.TomlException(new "Unexpected character at end of line ('${p.src.front}')");
	}
}

fn unexpectedCharMsg(c: dchar) string
{
	return new "Unexpected character '${c}'.";
}

// # This is a comment.
fn parseComment(ref p: Parser)
{
	util.match(ref p.src, '#');
	p.esink.commentStart();
	commentStartIndex := p.src.save();
	while (!p.src.eof && p.src.front != '\n' && !(p.src.front == '\r' && p.src.following == '\n')) {
		p.src.popFront();
	}
	p.esink.stringContent(p.src.sliceFrom(commentStartIndex));
	if (util.matchIf(ref p.src, '\r')) {
		util.match(ref p.src, '\n');
	}
	p.esink.commentEnd();
}

// key = "value"
fn parseKeyValue(ref p: Parser)
{
	keyStart := p.src.save();
	key: string;
	if (p.src.front != '"' && p.src.front != '\'') {
		// bare key
		while (!p.src.eof && (ascii.isAlphaNum(p.src.front) || p.src.front == '_' || p.src.front == '-')) {
			p.src.popFront();
		}
		key = p.src.sliceFrom(keyStart);
		if (key.length == 0) {
			throw new util.TomlException("Zero length bare key.");
		}
	} else {
		key = util.parseString(ref p.src);
	}

	skipTomlWhitespace(ref p);
	util.match(ref p.src, '=');
	skipTomlWhitespace(ref p);

	p.esink.keyValueStart(key);
	parseValue(ref p);
	p.esink.keyValueEnd(key);
}

fn parseInlineTable(ref p: Parser)
{
	p.esink.inlineTableStart();

	util.match(ref p.src, '{');
	skipTomlWhitespace(ref p);
	while (!p.src.eof && p.src.front != '}') {
		parseKeyValue(ref p);
		util.matchIf(ref p.src, ',');
		skipTomlWhitespace(ref p);
	}
	util.match(ref p.src, '}');

	p.esink.inlineTableEnd();
}

// [section]
fn parseTable(ref p: Parser)
{
	if (p.src.following == '[') {
		parseTableArray(ref p);
		return;
	}

	util.match(ref p.src, '[');
	tableNameStart := p.src.save();
	while (!p.src.eof && p.src.front != ']') {
		p.src.popFront();
	}

	if (p.lastTable != "") {
		p.esink.tableEnd(p.lastTable);
	}
	tableName := p.src.sliceFrom(tableNameStart);
	p.esink.tableStart(tableName);
	p.lastTable = tableName;

	util.match(ref p.src, ']');
	skipEndOfLine(ref p);
}

// [[tablearray]]
fn parseTableArray(ref p: Parser)
{
	util.match(ref p.src, '[');
	util.match(ref p.src, '[');

	tableNameStart := p.src.save();
	while (!p.src.eof && p.src.front != ']') {
		p.src.popFront();
	}
	p.esink.tableArray(p.src.sliceFrom(tableNameStart));

	util.match(ref p.src, ']');
	util.match(ref p.src, ']');
}

// key = ->("value")<-
fn parseValue(ref p: Parser)
{
	switch (p.src.front) {
	case '"', '\'':
		parseStringValue(ref p);
		return;
	case '[':
		parseArray(ref p);
		return;
	case 't':
		parseBoolTrue(ref p);
		return;
	case 'f':
		parseBoolFalse(ref p);
		return;
	case '{':
		parseInlineTable(ref p);
		return;
	default:
		if (ascii.isDigit(p.src.front) || p.src.front == '-' || p.src.front == '+') {
			parseNumber(ref p);
			return;
		}
		throw new util.TomlException(unexpectedCharMsg(p.src.front));
	}
}

// "a simple string"
fn parseStringValue(ref p: Parser)
{
	str := util.parseString(ref p.src);
	p.esink.stringContent(str);
}

// an integer, double
fn parseNumber(ref p: Parser)
{
	ss: sink.StringSink;
	if (p.src.front == '+') {
		p.src.popFront();
	}
	numberStart := p.src.save();
	if (p.src.front == '-') {
		ss.sink("-");
		p.src.popFront();
	}
	isFloat := false;
	while (!p.src.eof && (ascii.isDigit(p.src.front) || p.src.front == '-' ||
		   p.src.front == 'T' || p.src.front == ':' || p.src.front == '_') ||
		   p.src.front == 'e' || p.src.front == 'E' || p.src.front == '.' || p.src.front == '+') {
		if (p.src.front == 'T' || (!isFloat && p.src.front == '-') || p.src.front == ':') {
			throw new util.TomlException("dates not supported");
		}
		if (p.src.front == 'e' || p.src.front == 'E' || p.src.front == '.') {
			isFloat = true;
		}
		if (p.src.front != '_') {
			ss.sink(utf.encode(p.src.front));
		}
		p.src.popFront();
	}
	numStr := ss.toString();

	try {
		if (!isFloat) {
			p.esink.integerContent(conv.toLong(numStr));
		} else {
			p.esink.floatContent(conv.toDouble(numStr));
		}
	} catch (e: conv.ConvException) {
		throw new util.TomlException("Bad number.");
	}
}

// [a, b, c] easy as [1, 2, 3] 
fn parseArray(ref p: Parser)
{
	util.match(ref p.src, '[');
	skipWhitespace(ref p);
	p.esink.arrayStart();
	while (p.src.front != ']') {
		parseValue(ref p);
		if (p.src.eof) {
			throw new util.TomlException("EOF while parsing array.");
		}
		skipWhitespace(ref p);
		util.matchIf(ref p.src, ',');
		skipWhitespace(ref p);
		if (p.src.front == '#') {
			parseComment(ref p);
			skipWhitespace(ref p);
		}
	}
	util.match(ref p.src, ']');
	p.esink.arrayEnd();
}

// true
fn parseBoolTrue(ref p: Parser)
{
	foreach (c: char; "true") {
		util.match(ref p.src, c);
	}
	p.esink.boolContent(true);
}

// false
fn parseBoolFalse(ref p: Parser)
{
	foreach (c: char; "false") {
		util.match(ref p.src, c);
	}
	p.esink.boolContent(false);
}
