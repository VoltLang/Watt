// Copyright 2016-2017, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Parse [Markdown](http://commonmark.org/) into HTML.
 *
 * `watt.markdown` attempts to be a fully compliant [CommonMark](http://commonmark.org)
 * parser. It takes Markdown input, and returns a string of HTML.
 */
module watt.markdown;

import watt.text.sink : Sink;

import watt.markdown.parser;
import watt.markdown.html;


/*!
 * Given a markdown string, return a string of HTML.
 *
 * ### Example
 * ```volt
 * filterMarkdown("**hello** `world`");  // Returns "<p><strong>hello</strong> <code>world</code></p>"
 * ```
 */
fn filterMarkdown(src: string) string
{
	doc := parse(src);
	return printHtml(doc);
}

/*!
 * Given a markdown string, put a string of HTML in a given @ref watt.text.sink.Sink.
 */
fn filterMarkdown(sink: Sink, src: string)
{
	doc := parse(src);
	printHtml(doc, sink);
}
