// Copyright © 2014-2017, Bernard Helyer.
// Copyright © 2014-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
/*!
 * Doccomment parsing and cleaning code.
 */
module watt.text.vdoc;

import core.exception;
import watt.text.string;
import watt.text.source;
import watt.text.sink;
import watt.text.utf;
import watt.text.ascii;


/*!
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
	if (comment[0..2] == "*!") {
		commentChar = '*';
	} else if (comment[0..2] == "+!") {
		commentChar = '+';
	} else if (comment[0..2] == "/!") {
		commentChar = '/';
	} else {
		return comment;
	}

	ignoreWhitespace := true;
	foreach (i, c: dchar; comment) {
		if (i == comment.length - 1 && commentChar != '/' && c == '/') {
			continue;
		}
		if (i == 1 && c == '!') {
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

enum DocState
{
	Content,
	Brief,
	Param,
}

//! Interface for doc string consumers.
interface DocSink
{
	//! Signals the start of a brief comment section.
	fn briefStart(sink: Sink);
	//! Signals the end of a brief comment section.
	fn briefEnd(sink: Sink);

	//! Signals the start of a param comment section.
	fn paramStart(sink: Sink, direction: string, arg: string);
	//! Signals the end of a param comment section.
	fn paramEnd(sink: Sink);

	//! Signals the start of the full content.
	fn start(sink: Sink);
	//! Signals the end of the full content.
	fn end(sink: Sink);

	//! Regular text content.
	fn content(sink: Sink, state: DocState, d: string);
	//! p comment section.
	fn p(sink: Sink, state: DocState, d: string);
	//! link comment section.
	fn link(sink: Sink, state: DocState, target: string, text: string);
}

//! Given a doc string input, call dsink methods with the given sink as an argument.
fn parse(src: string, dsink: DocSink, sink: Sink)
{
	p: Parser;
	p.setup(src, dsink, DocState.Content);

	p.dsink.start(sink);
	p.commandLoop(sink);
	dsink.end(sink);
}


private:

//! Internal private parser struct.
struct Parser
{
	dsink: DocSink;
	state: DocState;
	src: SimpleSource;


	fn setup(ref old: Parser, src: string, state: DocState)
	{
		setup(src, old.dsink, state);
	}

	fn setup(src: string, dsink: DocSink, state: DocState)
	{
		this.src.source = src;
		this.dsink = dsink;
		this.state = state;
	}
}

//! Loop over src, calling contentDg as appropriate, and handleCommand for commands.
fn commandLoop(ref p: Parser, sink: Sink)
{
	while (!p.src.eof) {
		fn cond(c: dchar) bool { return c == '@'; }

		preCommand := p.decodeUntil(cond);
		if (preCommand.length > 0) {
			p.dsink.content(sink, p.state, preCommand);
		}

		last := p.src.front;
		p.src.popFront();

		if (p.src.eof) {
			// Just so we don't drop the last '@' in the source.
			if (last == '@') {
				p.dsink.content(sink, p.state, "@");
			}
			break;
		}

		command := p.getWord();
		if (!p.handleCommand(sink, command)) {
			p.dsink.content(sink, p.state, "@");
			p.dsink.content(sink, p.state, command);
		}
	}
}

//! Dispatch a command to its handler. Returns: true if handled.
fn handleCommand(ref p: Parser, sink: Sink, command: string) bool
{
	switch (command) {
	case "p": p.handleCommandP(sink); break;
	case "link": p.handleCommandLink(sink); break;
	case "brief": p.handleCommandBrief(sink); break;
	case "param": p.handleCommandParam(sink, ""); break;
	case "param[in]": p.handleCommandParam(sink, "in"); break;
	case "param[in,out]": p.handleCommandParam(sink, "in,out"); break;
	case "param[out]": p.handleCommandParam(sink, "out"); break;
	default: return false;
	}
	return true;
}

//! Parse an <at>p command.
fn handleCommandP(ref p: Parser, sink: Sink)
{
	p.eatWhitespace();
	arg := p.getLinkWord();
	p.dsink.p(sink, p.state, arg);
}

//! Parse an <at>link command.
fn handleCommandLink(ref p: Parser, sink: Sink)
{
	p.eatWhitespace();
	target := p.getLinkWord();

	fn cond(c: dchar) bool { return c == '@'; }
	preCommand := p.decodeUntil(cond);

	p.src.popFront();
	command := p.getWord();
	if (command != "endlink" || p.src.eof) {
		return;
	}

	p.dsink.link(sink, p.state, target, preCommand);
}

//! Parse an <at>param command.
fn handleCommandParam(ref p: Parser, sink: Sink, direction: string)
{
	p.eatWhitespace();
	arg := p.getWord();
	p.eatWhitespace();
	paramParagraph := p.getParagraph();


	sub: Parser;
	sub.setup(ref p, paramParagraph, DocState.Param);

	sub.dsink.paramStart(sink, direction, arg);
	sub.commandLoop(sink);
	sub.dsink.paramEnd(sink);
}

//! Parse an <at>brief command.
fn handleCommandBrief(ref p: Parser, sink: Sink)
{
	p.eatWhitespace();
	briefParagraph := p.getParagraph();

	sub: Parser;
	sub.setup(ref p, briefParagraph, DocState.Brief);

	sub.dsink.briefStart(sink);
	sub.commandLoop(sink);
	sub.dsink.briefEnd(sink);
}

//! Decode until we're at the end of the string, or an empty line.
fn getParagraph(ref p: Parser) string
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
	paragraph := p.decodeUntil(cond);
	if (paragraph.length > 0 && paragraph[$-1] == '\n') {
		paragraph = paragraph[0 .. $-1];  // eat the \n on the end.
		p.src.popFront(); // and don't include a \n in the remainder.
	}
	return paragraph;
}

//! Decode until we're at the end of the string, or a non word character.
fn getWord(ref p: Parser) string
{
	fn cond(c: dchar) bool { return !isAlphaNum(c) && c != '[' && c != ']'; }
	return p.decodeUntil(cond);
}

/*!
 * Get a link word, alpha num with dots in them.
 *
 * Trailing dots are not included.
 */
fn getLinkWord(ref p: Parser) string
{
	origin := p.src.save();
	while (!p.src.eof && p.isFrontLinkWord()) {
		p.src.popFront();
	}
	return p.src.sliceFrom(origin);
}

//! My we are awfully specific.
fn isFrontLinkWord(ref p: Parser) bool
{
	// Is the front character alpha num then its a link word.
	c := p.src.front;
	if (isAlphaNum(c)) {
		return true;
	}

	// Is the next characters .[alphanum] ?
	if (c != '.') {
		return false;
	}

	bool dummy;
	c = p.src.lookahead(1, out dummy);
	return isAlphaNum(c);
}

//! Decode until we're at the end of the string, or a non isWhite character.
fn eatWhitespace(ref p: Parser)
{
	fn cond(c: dchar) bool { return !isWhite(c); }
	p.decodeUntil(cond);
}

//! Decode until cond is true, or we're out of string.
fn decodeUntil(ref p: Parser, cond: dg(dchar) bool) string
{
	origin := p.src.save();
	while (!p.src.eof && !cond(p.src.front)) {
		p.src.popFront();
	}
	return p.src.sliceFrom(origin);
}
