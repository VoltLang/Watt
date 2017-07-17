// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Main importer for markdown parser.
module watt.text.markdown;

import watt.text.sink : Sink;

import watt.text.markdown.parser;
import watt.text.markdown.html;


fn filterMarkdown(src: string) string
{
	doc := parse(src);
	return printHtml(doc);
}

fn filterMarkdown(sink: Sink, src: string)
{
	doc := parse(src);
	printHtml(doc, sink);
}
