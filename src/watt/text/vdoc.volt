// Copyright © 2014-2017, Bernard Helyer.
// Copyright © 2014-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
/**
 * Doccomment parsing and cleaning code.
 */
module watt.text.vdoc;

import watt.text.string;
import watt.text.sink;


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
