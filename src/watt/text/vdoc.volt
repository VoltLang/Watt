// Copyright © 2014-2017, Bernard Helyer.
// Copyright © 2014-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
/**
 * Doccomment parsing and cleaning code.
 */
module watt.text.vdoc;

import watt.text.string;
import watt.text.sink;
import watt.text.utf;


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

interface DocSink
{
	/// Signals the start of a brief comment section.
	fn briefStart(sink: Sink);
	/// The content of a brief comment section.
	fn briefContent(d: string, sink: Sink);
	/// Signals the end of a brief comment section.
	fn briefEnd(sink: Sink);

	/// Signals the start of a param comment section.
	fn paramStart(arg: string, sink: Sink);
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

fn parse(src: string, dsink: DocSink, sink: Sink)
{
}
