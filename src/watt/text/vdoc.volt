// Copyright © 2014-2017, Bernard Helyer.
// Copyright © 2014-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
/**
 * Doccomment parsing and cleaning code.
 */
module watt.text.vdoc;

import core.exception;
import watt.text.string;
import watt.text.sink;
import watt.text.utf;
import watt.text.ascii;


fn rawToFull(doc: string) string
{
	s: StringSink;
	if (rawToFull(doc, s.sink)) {
		return s.toString();
	}

	return null;
}

fn rawToBrief(doc: string) string
{
	s: StringSink;
	if (rawToBrief(doc, s.sink)) {
		return s.toString();
	}

	return null;
}

fn rawToFull(doc: string, sink: Sink) bool
{
	dummy: bool;
	sink(cleanComment(doc, out dummy));
	return true;
}

fn rawToBrief(doc: string, sink: Sink) bool
{
	tmp := rawToFull(doc);

	index := indexOf(tmp, ".");
	if (index < 0) {
		return false;
	}

	// TODO do more cleaning.
	// Like turn all whitespace into a single whitespace.
	tmp = strip(tmp[0 .. index + 1]);

	sink(tmp);
	return true;
}

/**
 * Take a doc comment and remove comment cruft from it.
 */
fn cleanComment(comment: string, out isBackwardsComment: bool) string
{
	sink: StringSink;
	output := sink.sink;

	if (comment.length < 2) {
		return comment;
	}

	commentChar: char;
	if (comment[0..2] == "**") {
		commentChar = '*';
	} else if (comment[0..2] == "++") {
		commentChar = '+';
	} else if (comment[0..2] == "//") {
		commentChar = '/';
	} else {
		return comment;
	}

	ignoreWhitespace := true;
	foreach (i, c: dchar; comment) {
		if (i == comment.length - 1 && commentChar != '/' && c == '/') {
			continue;
		}
		if (i == 2 && c == '<') {
			isBackwardsComment = true;
			continue;  // Skip the '<'.
		}
		switch (c) {
		case '*', '+', '/':
			if (c == commentChar && ignoreWhitespace) {
				break;
			}
			goto default;
		case ' ', '\t':
			if (!ignoreWhitespace) {
				goto default;
			}
			break;
		case '\n':
			ignoreWhitespace = true;
			encode(output, '\n');
			break;
		default:
			ignoreWhitespace = false;
			encode(output, c);
			break;
		}
	}

	return sink.toString();
}

/// Interface for doc string consumers.
interface DocSink
{
	/// Signals the start of a brief comment section.
	fn briefStart(sink: Sink);
	/// The content of a brief comment section.
	fn briefContent(d: string, sink: Sink);
	/// Signals the end of a brief comment section.
	fn briefEnd(sink: Sink);

	/// Signals the start of a param comment section.
	fn paramStart(direction: string, arg: string, sink: Sink);
	/// The content of a param comment section.
	fn paramContent(d: string, sink: Sink);
	/// Signals the end of a param comment section.
	fn paramEnd(sink: Sink);

	/// Signals the start of the full content.
	fn start(sink: Sink);
	/// A text portion of the comment.
	fn content(d: string, sink: Sink);
	/// Signals the end of the full content.
	fn end(sink: Sink);

	// p comment section.
	fn p(d: string, sink: Sink);
	// link comment section.
	fn link(link: string, sink: Sink);
}

/// Given a doc string input, call dsink methods with the given sink as an argument.
fn parse(src: string, dsink: DocSink, sink: Sink)
{
	dsink.start(sink);
	i: size_t;
	fn content(s: string, snk: Sink) { dsink.content(s, snk); }
	commandLoop(src, dsink, sink, content, ref i);
	dsink.end(sink);
}

/// Loop over src, calling contentDg as appropriate, and handleCommand for commands.
private fn commandLoop(src: string, dsink: DocSink, sink: Sink, contentDg: dg(string, Sink), ref i: size_t)
{
	while (i < src.length) {
		fn cond(c: dchar) bool { return c == '@'; }
		preCommand := decodeUntil(src, ref i, cond);
		if (preCommand.length > 0) {
			contentDg(preCommand, sink);
		}
		i++;  // skip '@'
		if (i >= src.length) {
			if (i - 1 < src.length) {
				contentDg("@", sink);
			}
			break;
		}
		command := getWord(src, ref i);
		if (!handleCommand(src, command, dsink, sink, ref i)) {
			contentDg("@" ~ command, sink);
		}
	}
}

/// Dispatch a command to its handler. Returns: true if handled.
private fn handleCommand(src: string, command: string, dsink: DocSink, sink: Sink, ref i: size_t) bool
{
	switch (command) {
	case "p": handleCommandP(src, dsink, sink, ref i); break;
	case "link": handleCommandLink(src, dsink, sink, ref i); break;
	case "brief": handleCommandBrief(src, dsink, sink, ref i); break;
	case "param": handleCommandParam(src, "", dsink, sink, ref i); break;
	case "param[in]": handleCommandParam(src, "in", dsink, sink, ref i); break;
	case "param[in,out]": handleCommandParam(src, "in,out", dsink, sink, ref i); break;
	case "param[out]": handleCommandParam(src, "out", dsink, sink, ref i); break;
	default: return false;
	}
	return true;
}

/// Parse an <at>p command.
private fn handleCommandP(src: string, dsink: DocSink, sink: Sink, ref i: size_t)
{
	eatWhitespace(src, ref i);
	arg: string;
	if (i >= src.length) {
		arg = "";
	} else {
		arg = getWord(src, ref i);
	}
	dsink.p(arg, sink);
}

/// Parse an <at>link command.
private fn handleCommandLink(src: string, dsink: DocSink, sink: Sink, ref i: size_t)
{
	eatWhitespace(src, ref i);
	fn cond(c: dchar) bool { return c == '@'; }
	preCommand := decodeUntil(src, ref i, cond);
	i++;  // skip '@' etc
	command := getWord(src, ref i);
	if (command != "endlink" || i >= src.length) {
		return;
	}
	dsink.link(preCommand, sink);
}

/// Parse an <at>param command.
private fn handleCommandParam(src: string, direction: string, dsink: DocSink, sink: Sink, ref i: size_t)
{
	eatWhitespace(src, ref i);
	arg := getWord(src, ref i);
	dsink.paramStart(direction, arg, sink);
	eatWhitespace(src, ref i);
	paramParagraph := getParagraph(src, ref i);

	subIndex: size_t;
	fn content(s: string, snk: Sink) { dsink.paramContent(s, snk); }
	commandLoop(paramParagraph, dsink, sink, content, ref subIndex);

	dsink.paramEnd(sink);
}

/// Parse an <at>brief command.
private fn handleCommandBrief(src: string, dsink: DocSink, sink: Sink, ref i: size_t)
{
	dsink.briefStart(sink);
	eatWhitespace(src, ref i);
	briefParagraph := getParagraph(src, ref i);

	subIndex: size_t;
	fn content(s: string, snk: Sink) { dsink.briefContent(s, snk); }
	commandLoop(briefParagraph, dsink, sink, content, ref subIndex);

	dsink.briefEnd(sink);
}

/// Decode until we're at the end of the string, or an empty line.
private fn getParagraph(src: string, ref i: size_t) string
{
	lastChar: dchar;
	fn cond(c: dchar) bool
	{
		if (lastChar == '\n' && c == '\n') {
			return true;
		}
		lastChar = c;
		return false;
	}
	paragraph := decodeUntil(src, ref i, cond);
	if (paragraph.length > 0 && paragraph[$-1] == '\n') {
		paragraph = paragraph[0 .. $-1];  // eat the \n on the end.
		i++;  // and don't include a \n in the remainder.
	}
	return paragraph;
}

/// Decode until we're at the end of the string, or a non word character.
private fn getWord(src: string, ref i: size_t) string
{
	fn cond(c: dchar) bool { return !isAlphaNum(c) && c != '[' && c != ']'; }
	return decodeUntil(src, ref i, cond);
}

/// Decode until we're at the end of the string, or a non isWhite character.
private fn eatWhitespace(src: string, ref i: size_t)
{
	fn cond(c: dchar) bool { return !isWhite(c); }
	decodeUntil(src, ref i, cond);
}

/// Decode until cond is true, or we're out of string.
private fn decodeUntil(src: string, ref i: size_t, cond: dg(dchar) bool) string
{
	origin := i;
	while (i < src.length) {
		prevIndex := i;
		c := decode(src, ref i);
		if (cond(c)) {
			i = prevIndex;
			break;
		}
	}
	return src[origin .. i];
}
