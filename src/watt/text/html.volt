// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Functions for dealing with HTML.
module watt.text.html;

import watt.conv: toString, toUint;
import watt.text.sink: Sink, StringSink;
import watt.text.string: indexOf, replace;


/*!
 * Returns the HTML escaped version of a given string.
 */
fn htmlEscape(str: string) string
{
	dst: StringSink;
	htmlEscape(dst.sink, str);
	return dst.toString();
}

/*!
 * Given an HTML escaped string `str`, unescape that string.
 * ### Examples
 *     htmlUnescape("&quot;hello world&quot;");  // Returns "hello world"
 */
fn htmlUnescape(str: string) string
{
	str = str.replace("&#39;", "\'");
	str = str.replace("&quot;", "\"");
	str = str.replace("&lt;", "<");
	str = str.replace("&gt;", ">");
	str = str.replace("&amp;", "&");
	return str;
}

/*!
 * Writes the HTML escaped version of a given string to the given dgt.
 */
fn htmlEscape(dgt: Sink, str: string, ignore: string = "")
{
	i, org: size_t;
	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		ch: char = str[i];
		switch (ch) {
		default:
			i++;
			continue;
		case '\'', '"', '<', '>', '&':
			if (ignore.indexOf(ch) >= 0) {
				goto default;
			}
			break;
		}

		if (i > org) {
			dgt(str[org .. i]);
		}

		org = ++i;

		switch (ch) {
		case '\'': dgt("&#39;"); break;
		case '"': dgt("&quot;"); break;
		case '<': dgt("&lt;"); break;
		case '>': dgt("&gt;"); break;
		case '&': dgt("&amp;"); break;
		default:
			assert(false);
		}
	}

	if (i > org) {
		dgt(str[org .. i]);
	}
}

/*!
 * Returns the HTML escaped version of a given string, ignoring any html tags.
 */
fn htmlEscapeIgnoreTags(str: string) string
{
	dst: StringSink;
	htmlEscapeIgnoreTags(dst.sink, str);
	return dst.toString();
}

/*!
 * Writes the HTML escaped version of a given string to
 * the given dgt, ignoring any tags.
 */
fn htmlEscapeIgnoreTags(dgt: Sink, str: string)
{
	eatingHtmlTag: bool;
	i, org: size_t;

	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		ch: char = str[i];

		if (eatingHtmlTag) {
			i++;
			eatingHtmlTag = ch != '>';
			continue;
		}

		switch (ch) {
		default:
			i++;
			continue;
		case '<':
			if (str[i .. $].indexOf('>')) {
				i++;
				eatingHtmlTag = true;
				continue;
			} else {
				goto case '"';
			}
		case '>', '\'', '"', '&':
			break;
		}

		if (i > org) {
			dgt(str[org .. i]);
		}

		org = ++i;

		switch (ch) {
		case '"': dgt("&quot;"); break;
		case '&': dgt("&amp;"); break;
		case '\'': dgt("&#39;"); break;
		case '<': dgt("&lt;"); break;
		case '>': dgt("&gt;"); break;
		default:
			assert(false);
		}
	}

	if (i > org) {
		dgt(str[org .. i]);
	}
}

/*!
 * Escape every single character.
 */
fn htmlEscapeAll(str: string) string
{
	dst: StringSink;
	htmlEscapeAll(dst.sink, str);
	return dst.toString();
}

/*!
 * Escape every single character.
 */
fn htmlEscapeAll(dgt: Sink, str: string)
{
	foreach (d: dchar; str) {
		dgt("&#");
		// @TODO add sink version of to string.
		dgt(toString(cast(u32)d));
		dgt(";");
	}
}
