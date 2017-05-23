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
	// TODO
	sink(doc);

	return true;
}

fn rawToBrief(doc: string, sink: Sink) bool
{
	// TODO
	index := indexOf(".", doc);
	if (index < 0) {
		return false;
	}

	sink(doc[0 .. index + 1]);
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
