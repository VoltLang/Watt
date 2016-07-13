// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.html;

import watt.conv : toString, toUint;
import watt.text.sink : Sink, StringSink;
import watt.text.string : indexOf;


/**
 * Returns the HTML escaped version of a given string.
 * According to the OWASP rules.
 */
fn htmlEscape(str : string) string
{
	dst : StringSink;
	htmlEscape(dst.sink, str);
	return dst.toString();
}

/**
 * Writes the HTML escaped version of a given string to the given dg.
 * According to the OWASP rules:
 */
fn htmlEscape(dg : Sink, str : string)
{
	i, org : size_t;
	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		ch : char = str[i];
		switch (ch) {
		default:
			i++;
			continue;
		case '\'', '"', '<', '>', '&':
			break;
		}

		if (i > org) {
			dg(str[org .. i]);
		}

		org = ++i;

		switch (ch) {
		case '\'': dg("&#39;"); break;
		case '"': dg("&quot;"); break;
		case '<': dg("&lt;"); break;
		case '>': dg("&gt;"); break;
		case '&': dg("&amp;"); break;
		default:
			assert(false);
		}
	}

	if (i > org) {
		dg(str[org .. i]);
	}
}

/**
 * Returns the HTML escaped version of a given string, ignoring any html tags.
 */
fn htmlEscapeIgnoreTags(str : string) string
{
	dst : StringSink;
	htmlEscapeIgnoreTags(dst.sink, str);
	return dst.toString();
}

/**
 * Writes the HTML escaped version of a given string to
 * the given dg, ignoring any tags.
 */
fn htmlEscapeIgnoreTags(dg : Sink, str : string)
{
	eatingHtmlTag : bool;
	i, org : size_t;

	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		ch : char = str[i];

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
			dg(str[org .. i]);
		}

		org = ++i;

		switch (ch) {
		case '"': dg("&quot;"); break;
		case '&': dg("&amp;"); break;
		case '\'': dg("&#39;"); break;
		case '<': dg("&lt;"); break;
		case '>': dg("&gt;"); break;
		default:
			assert(false);
		}
	}

	if (i > org) {
		dg(str[org .. i]);
	}
}

/**
 * Escape every single character.
 */
fn htmlEscapeAll(str : string) string
{
	dst : StringSink;
	htmlEscapeAll(dst.sink, str);
	return dst.toString();
}

/**
 * Escape every single character.
 */
fn htmlEscapeAll(dg : Sink, str : string)
{
	foreach (d : dchar; str) {
		dg("&#");
		// @TODO add sink version of to string.
		dg(toString(cast(u32)d));
		dg(";");
	}
}
