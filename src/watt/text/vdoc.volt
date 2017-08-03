// Copyright © 2014-2017, Bernard Helyer.
// Copyright © 2014-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
/*!
 * Doccomment parsing and cleaning code.
 */
module watt.text.vdoc;

import core.exception;
import watt.conv;
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


	whiteCal := u32.max;
	whiteNum := 1u; // One extra
	calibrating := true;
	ignoreWhitespace := true;
	foreach (i, c: dchar; comment) {
		if (i == comment.length - 1 && commentChar != '/' && c == '/') {
			continue;
		}

		switch (c) {
		case '<':
			if (whiteNum < whiteCal) {
				isBackwardsComment = true;
				whiteNum += 1;
				break;
			}
			goto default;
		case '!':
			if (whiteNum < whiteCal) {
				whiteNum += 1;
				break;
			}
			goto default;
		case '*', '+', '/':
			if (c == commentChar && ignoreWhitespace) {
				whiteNum += 1;
				break;
			}
			goto default;
		case '\t':
			whiteNum += 7;
			goto case;
		case ' ':
			whiteNum += 1;
			if (!ignoreWhitespace || whiteNum > whiteCal) {
				goto default;
			}
			break;
		case '\r':
			ignoreWhitespace = true;
			encode(output, '\r');
			whiteNum = 0;
			break;
		case '\n':
			ignoreWhitespace = true;
			encode(output, '\n');
			whiteNum = 0;
			break;
		default:
			if (calibrating) {
				whiteCal = whiteNum;
				calibrating = false;
			}
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
	Section,
}

enum DocSection
{
	SeeAlso,
	Return,
	SideEffect,
	Throw,
}

//! Interface for doc string consumers.
interface DocSink
{
	//! Signals the start of the full content.
	fn start(sink: Sink);
	//! Signals the end of the full content.
	fn end(sink: Sink);

	//! Signals the start of a brief comment section.
	fn briefStart(sink: Sink);
	//! Signals the end of a brief comment section.
	fn briefEnd(sink: Sink);

	//! Signals the start of a param comment section.
	fn paramStart(sink: Sink, direction: string, arg: string);
	//! Signals the end of a param comment section.
	fn paramEnd(sink: Sink);

	//! Signals the start of a section, these are never nested.
	fn sectionStart(sink: Sink, sec: DocSection);
	//! Signals the end of a section, these are never nested.
	fn sectionEnd(sink: Sink, sec: DocSection);

	//! Regular text content.
	fn content(sink: Sink, state: DocState, d: string);
	//! p comment section.
	fn p(sink: Sink, state: DocState, d: string);
	//! link comment section.
	fn link(sink: Sink, state: DocState, target: string, text: string);

	//! The defgroup command.
	fn defgroup(sink: Sink, group: string, text: string);
	//! The ingroup command, may get called multiple times.
	fn ingroup(sink: Sink, group: string);
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

//! Does the given command break a paragraph.
fn isBreakingCommand(command: string) bool
{
	command = toLower(command);
	switch (command) {
	case "param", "param[in]", "param[in,out]", "param[out]":
	case "ingroup", "defgroup":
	case "brief":
	case "return", "returns":
	case "throw", "throws":
	case "se", "sideeffect", "sideeffects":
	case "see", "sa":
		return true;
	case "p", "ref", "link":
		return false;
	default:
		return false;
	}
}

//! Dispatch a command to its handler. Returns: true if handled.
fn handleCommand(ref p: Parser, sink: Sink, command: string) bool
{
	command = toLower(command);
	switch (command) {
	case "p": p.handleCommandP(sink); break;
	case "ref": p.handleCommandRef(sink); break;
	case "link": p.handleCommandLink(sink); break;
	case "brief": p.handleCommandBrief(sink); break;
	case "param": p.handleCommandParam(sink, ""); break;
	case "param[in]": p.handleCommandParam(sink, "in"); break;
	case "param[in,out]": p.handleCommandParam(sink, "in,out"); break;
	case "param[out]": p.handleCommandParam(sink, "out"); break;
	case "ingroup": p.handleCommandInGroup(sink); break;
	case "defgroup": p.handleCommandDefGroup(sink); break;
	case "see", "sa":
		p.handleCommandSection(sink, DocSection.SeeAlso); break;
	case "return", "returns":
		p.handleCommandSection(sink, DocSection.Return); break;
	case "throw", "throws":
		p.handleCommandSection(sink, DocSection.Throw); break;
	case "se", "sideeffect", "sideeffects":
		p.handleCommandSection(sink, DocSection.SideEffect); break;
	default: return false;
	}
	return true;
}

//! Parse an <at>p command.
fn handleCommandP(ref p: Parser, sink: Sink)
{
	p.eatWhitespace();
	arg := p.getThing();
	p.dsink.p(sink, p.state, arg);
}

//! Parse an <at>ref command.
fn handleCommandRef(ref p: Parser, sink: Sink)
{
	p.eatWhitespace();
	target := p.getLinkWord();
	p.dsink.link(sink, p.state, target, null);
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

//! Parse a generic section command.
fn handleCommandSection(ref p: Parser, sink: Sink, sec: DocSection)
{
	paragraph := p.getParagraph();

	sub: Parser;
	sub.setup(ref p, paragraph, DocState.Section);

	sub.dsink.sectionStart(sink, sec);
	sub.commandLoop(sink);
	sub.dsink.sectionEnd(sink, sec);
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

//! Parse an <at>defgroup command.
fn handleCommandDefGroup(ref p: Parser, sink: Sink)
{
	str := p.getRestOfLine();

	sub: Parser;
	sub.setup(ref p, str, p.state);

	sub.eatWhitespace();
	group := sub.getWord();
	text := sub.getRestOfLine();
	sub.dsink.defgroup(sink, group, text);
}

//! Parse an <at>ingroup command.
fn handleCommandInGroup(ref p: Parser, sink: Sink)
{
	str := p.getRestOfLine();

	sub: Parser;
	sub.setup(ref p, str, p.state);

	while (true) {
		sub.eatWhitespace();
		group := sub.getWord();
		if (group !is null) {
			sub.dsink.ingroup(sink, group);
		} else {
			break;
		}
	}
}

fn getParagraph(ref p: Parser) string
{
	return p.src.getParagraph();
}

//! Decode until we're at the end of the string, or an empty line.
fn getParagraph(ref src: SimpleSource) string
{
	lastChar: dchar;
	fn cond(c: dchar) bool
	{
		if (c == '@') {
			return true;
		}

		if (lastChar == '\n' && c == '\n') {
			return true;
		}
		lastChar = c;
		return false;
	}

	origin := src.save();

	// This loop checks for any commands that breaks paragraphs.
	while (true) {
		src.decodeUntil(cond);

		if (src.front == '@') {
			tmp := src;
			tmp.popFront();
			command := tmp.getWord();

			if (isBreakingCommand(command)) {
				break;
			}

			// Skip the '@' and let it continue.
			src.popFront();
		} else {
			break;
		}
	}

	paragraph := src.sliceFrom(origin);

	if (paragraph.length > 1 && paragraph[$-1] == '\n') {
		// eat the \n on the end.
		paragraph = paragraph[0 .. $-1];

		// If we didn't end on a command don't
		// include a \n in the remainder.
		if (src.front != '@') {
			src.popFront();
		}
	}

	return paragraph;
}

fn getWord(ref p: Parser) string
{
	return p.src.getWord();
}

//! Decode until we're at the end of the string, or a non word character.
fn getWord(ref src: SimpleSource) string
{
	fn cond(c: dchar) bool { 
		switch (c) {
		case '[', ']', '_': return false;
		default: return !isAlphaNum(c);
		}
	}
	return src.decodeUntil(cond);
}

fn getThing(ref p: Parser) string
{
	return p.src.getThing();
}

/*!
 * Decode until we're at the end of the string, or a non thing character.
 *
 * A thing is very losely defined as a character string that could be ident or
 * type. So `f32[4]` is a thing, as is `arr[4].field`. But from `foo.` only
 * `foo` is a thing, notince that trailing `.` is not included.
 */
fn getThing(ref src: SimpleSource) string
{
	fn cond(c: dchar) bool { 
		switch (c) {
		case '.':
			f := src.following;
			return !isAlpha(f) && f != '_';
		case '[', ']', '_': return false;
		default: return !isAlphaNum(c);
		}
	}
	return src.decodeUntil(cond);
}

fn getRestOfLine(ref p: Parser) string
{
	return p.src.getRestOfLine();
}

//! Get the rest of this line, newline is included.
fn getRestOfLine(ref src: SimpleSource) string
{
	origin := src.save();
	while (!src.eof && src.front != '\n') {
		src.popFront();
	}
	src.popFront();
	ret := src.sliceFrom(origin);
	return ret;
}

fn getLinkWord(ref p: Parser) string
{
	return p.src.getLinkWord();
}

/*!
 * Get a link word, alpha num with dots in them.
 *
 * Trailing dots are not included.
 */
fn getLinkWord(ref src: SimpleSource) string
{
	origin := src.save();
	while (!src.eof && src.isFrontLinkWord()) {
		src.popFront();
	}
	return src.sliceFrom(origin);
}

//! My we are awfully specific.
fn isFrontLinkWord(ref src: SimpleSource) bool
{
	// Is the front character alpha num then its a link word.
	c := src.front;
	if (isAlphaNum(c)) {
		return true;
	}

	// Is the next characters .[alphanum] ?
	if (c != '.') {
		return false;
	}

	bool dummy;
	c = src.lookahead(1, out dummy);
	return isAlphaNum(c);
}

fn eatWhitespace(ref p: Parser)
{
	p.src.eatWhitespace();
}

//! Decode until we're at the end of the string, or a non isWhite character.
fn eatWhitespace(ref src: SimpleSource)
{
	fn cond(c: dchar) bool { return !isWhite(c); }
	src.decodeUntil(cond);
}

fn decodeUntil(ref p: Parser, cond: dg(dchar) bool) string
{
	return decodeUntil(ref p.src, cond);
}

//! Decode until cond is true, or we're out of string.
fn decodeUntil(ref src: SimpleSource, cond: dg(dchar) bool) string
{
	origin := src.save();
	while (!src.eof && !cond(src.front)) {
		src.popFront();
	}
	return src.sliceFrom(origin);
}
