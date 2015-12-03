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
string htmlEscape(string str)
{
	StringSink dst;
	htmlEscape(dst.sink, str);
	return dst.toString();
}

/**
 * Writes the HTML escaped version of a given string to the given dg.
 * According to the OWASP rules:
 */
void htmlEscape(Sink dg, string str)
{
	size_t i, org;
	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		char ch = str[i];
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
string htmlEscapeIgnoreTags(string str)
{
	StringSink dst;
	htmlEscapeIgnoreTags(dst.sink, str);
	return dst.toString();
}

/**
 * Writes the HTML escaped version of a given string to
 * the given dg, ignoring any tags.
 */
void htmlEscapeIgnoreTags(Sink dg, string str)
{
	bool eatingHtmlTag;
	size_t i, org;

	// This is okay because we don't escape UTF-8 codes.
	while (i < str.length) {
		char ch = str[i];

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
string htmlEscapeAll(string str)
{
	StringSink dst;
	htmlEscapeAll(dst.sink, str);
	return dst.toString();
}

/**
 * Escape every single character.
 */
void htmlEscapeAll(Sink dg, string str)
{
	foreach (dchar d; str) {
		dg("&#");
		// @TODO add sink version of to string.
		dg(toString(cast(uint)d));
		dg(";");
	}
}
