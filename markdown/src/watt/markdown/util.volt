// Copyright 2016-2017, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
//! Utils for markdown AST.
module watt.markdown.util;

import watt.io;
import watt.markdown.ast;
import watt.text.ascii;
import watt.text.utf;
import watt.text.sink;
import watt.text.string;
import watt.text.format;
import watt.conv;


//! Create a Document node and return it.
fn buildDocument() Document
{
	ret := new Document();
	ret.type = Type.Document;
	return ret;
}

//! Create a BlockQuote node, add it to @p children and return it.
fn addBlockQuote(ref children: Node[]) BlockQuote
{
	ret := new BlockQuote();
	ret.type = Type.BlockQuote;
	children ~= ret;
	return ret;
}

//! Create a List node, add it to @p children and return it.
fn addList(ref children: Node[]) List
{
	ret := new List();
	ret.type = Type.List;
	children ~= ret;
	return ret;
}

//! Create a Item node, add it to @p children and return it.
fn addItem(ref children: Node[]) Item
{
	ret := new Item();
	ret.type = Type.Item;
	children ~= ret;
	return ret;
}

//! Create a CodeBlock node, add it to @p children and return it.
fn addCodeBlock(ref children: Node[], str: string, info: string) CodeBlock
{
	ret := new CodeBlock();
	ret.type = Type.CodeBlock;
	ret.str = str;
	ret.info = info;
	children ~= ret;
	return ret;
}

//! Create a HtmlBlock node, add it to @p children and return it.
fn addHtmlBlock(ref children: Node[], str: string) HtmlBlock
{
	ret := new HtmlBlock();
	ret.type = Type.HtmlBlock;
	ret.str = str;
	children ~= ret;
	return ret;
}

//! Create an HtmlBlock node.
fn buildHtmlBlock() HtmlBlock
{
	ret := new HtmlBlock();
	ret.type = Type.HtmlBlock;
	return ret;
}

//! Create a Paragraph node, add it to @p children and return it.
fn addParagraph(ref children: Node[]) Paragraph
{
	ret := new Paragraph();
	ret.type = Type.Paragraph;
	children ~= ret;
	return ret;
}

//! Create a Paragraph node, don't add it anywhere.
fn buildParagraph() Paragraph
{
	ret := new Paragraph();
	ret.type = Type.Paragraph;
	return ret;
}

//! Create a Heading node, add it to @p children and return it.
fn addHeading(ref children: Node[], level: u32) Heading
{
	ret := new Heading();
	ret.type = Type.Heading;
	ret.level = level;
	children ~= ret;
	return ret;
}

//! Create a Heading node, don't add it anywhere.
fn buildHeading(level: u32) Heading
{
	ret := new Heading();
	ret.type = Type.Heading;
	ret.level = level;
	return ret;
}

//! Create a ThematicBreak node, add it to @p children and return it.
fn addThematicBreak(ref children: Node[]) ThematicBreak
{
	ret := new ThematicBreak();
	ret.type = Type.ThematicBreak;
	children ~= ret;
	return ret;
}

//! Create a Text node, add it to @p children and return it.
fn addText(ref children: Node[], str: string) Text
{
	ret := new Text();
	ret.type = Type.Text;
	ret.str = str;
	children ~= ret;
	return ret;
}

//! Create a Text node, don't add it anywhere.
fn buildText(str: string) Text
{
	ret := new Text();
	ret.type = Type.Text;
	ret.str = str;
	return ret;
}

//! Create a Softbreak node, add it to @p children and return it.
fn addSoftbreak(ref children: Node[]) Softbreak
{
	ret := new Softbreak();
	ret.type = Type.Softbreak;
	children ~= ret;
	return ret;
}

//! Create a Linebreak node, add it to @p children and return it.
fn addLinebreak(ref children: Node[]) Linebreak
{
	ret := new Linebreak();
	ret.type = Type.Linebreak;
	children ~= ret;
	return ret;
}

//! Create a Code node, add it to @p children and return it.
fn addCode(ref children: Node[], str: string) Code
{
	ret := new Code();
	ret.type = Type.Code;
	ret.str = str;
	children ~= ret;
	return ret;
}

//! Create a Code node.
fn buildCode(str: string) Code
{
	ret := new Code();
	ret.type = Type.Code;
	ret.str = str;
	return ret;
}

//! Create an HtmlInline node, add it to @p children and return it.
fn addHtmlInline(ref children: Node[], str: string) HtmlInline
{
	ret := new HtmlInline();
	ret.type = Type.HtmlInline;
	ret.str = str;
	children ~= ret;
	return ret;
}

//! Build an HtmlInline node.
fn buildHtmlInline(str: string) HtmlInline
{
	ret := new HtmlInline();
	ret.type = Type.HtmlInline;
	ret.str = str;
	return ret;
}

//! Create a Emph node, add it to @p children and return it.
fn addEmph(ref children: Node[]) Emph
{
	ret := new Emph();
	ret.type = Type.Emph;
	children ~= ret;
	return ret;
}

//! Create a Emph node, don't add it anywhere.
fn buildEmph() Emph
{
	ret := new Emph();
	ret.type = Type.Emph;
	return ret;
}

//! Create a Strong node, don't add it anywhere.
fn buildStrong() Strong
{
	ret := new Strong();
	ret.type = Type.Strong;
	return ret;
}

//! Create a Strong node, add it to @p children and return it.
fn addStrong(ref children: Node[]) Strong
{
	ret := new Strong();
	ret.type = Type.Strong;
	children ~= ret;
	return ret;
}

//! Create a Link node, add it to @p children and return it.
fn addLink(ref children: Node[], url: string, title: string) Link
{
	ret := new Link();
	ret.type = Type.Link;
	ret.url = url;
	ret.title = title;
	children ~= ret;
	return ret;
}

//! Create a Link node.
fn buildLink() Link
{
	ret := new Link();
	ret.type = Type.Link;
	return ret;
}

//! Create a Link node.
fn buildLink(url: string, title: string) Link
{
	ret := new Link();
	ret.type = Type.Link;
	ret.url = url;
	ret.title = title;
	return ret;
}

//! Create a Image node, add it to @p children and return it.
fn addImage(ref children: Node[], url: string, title: string) Image
{
	ret := new Image();
	ret.type = Type.Image;
	ret.url = url;
	ret.title = title;
	children ~= ret;
	return ret;
}

//! Build an Image node.
fn buildImage(url: string, alt: string, title: string) Image
{
	ret := new Image();
	ret.type = Type.Image;
	ret.url = url;
	ret.alt = alt;
	ret.title = title;
	return ret;
}

/*
 * Parsing utility functions.
 */

//! Consume characters until a character is found.
fn consumeUntilChar(ref str: string, out outStr: string, c: char) bool
{
	found := false;
	i: size_t;
	for (i = 0; i < str.length; ++i) {
		if (i < str.length - 2 && str[i] == '\\' && str[i+1] == '\\') {
			i += 2;
		}
		if (i < str.length - 2 && str[i] == '\\' && str[i+1] == c) {
			i++;
			continue;
		}
		if (str[i] == c) {
			found = true;
			break;
		}
	}
	outStr = str[0 .. i];
	str = str[i .. $];
	return found;
}

//! Consume a link tag.
fn consumeTag(ref str: string, out tag: string) bool
{
	i: size_t;
	if (str.length == 0 || !isAlpha(str[i])) {
		return false;
	}
	i++;
	while (i < str.length && (isAlphaNum(str[i]) || str[i] == '-')) {
		i++;
	}
	tag = toLower(str[0 .. i]);
	str = str[i .. $];
	return true;
}

//! Consume one character.
fn consumeChar(ref str: string, c: char) bool
{
	if (str.length == 0 || str[0] != c) {
		return false;
	}
	str = str[1 .. $];
	return true;
}

//! Consume whitespace.
fn consumeWhitespace(ref str: string)
{
	while (str.length > 0 && isWhite(str[0])) {
		str = str[1 .. $];
	}
}

//! Consume a URL.
fn consumeUrl(ref str: string, out url: string) bool
{
	if (str.length == 0) {
		return false;
	}
	i: size_t;
	angle := str[0] == '<';
	if (angle) {
		i++;
	}
	while (i < str.length && !isWhite(str[i]) && (!angle || str[i] != '>')) {
		i++;
	}
	if (i == 0) {
		return false;
	}
	if (angle && (i >= str.length || str[i] != '>')) {
		return false;
	}
	url = str[0 .. i];
	str = str[i .. $];
	if (angle) {
		url = url[1 .. $];
		str = str[1 .. $];
	}
	return true;
}

enum CODE_INDENT = 4;

//! Count the whitespace at the beginning of a string.
fn countLeadingWhitespace(str: string) size_t
{
	dummy: size_t;
	return countContiguousWhitespace(str, size_t.max, ref dummy);
}

/*!
 * Starting from @p i, count how much whitespace until the first nonwhitespace character.
 * If as much or more whitespace than @p maxLength is counted, return immediately.
 * Tabs count as 4.
 */
fn countContiguousWhitespace(str: string, maxLength: size_t, ref i: size_t) size_t
{
	if (i >= str.length) {
		return 0;
	}
	indentLength: size_t;
	c: dchar;
	do {
		c = decode(str, ref i);
		switch (c) {
		case ' ':
			indentLength++;
			break;
		case '\t':
			indentLength += 4;
			break;
		default:
			return indentLength;
		}
	} while (i < str.length && indentLength < maxLength);
	return indentLength;
}

/*!
 * Remove a delimiter length worth of characters from the front of @p str.
 * Taking into account tabs etc.
 */
fn removeDelimiter(str: string, delimiter: size_t, forceFourTab: bool = false) string
{
	if (str.length < delimiter || delimiter == 0) {
		return str;
	}

	tabSize: size_t = 4;
	accum: size_t;
	while (str.length > 0 && accum < delimiter) {
		if (str[0] == '\t') {
			if (forceFourTab) {
				/* This is a hack. The tab stops need to be considered for the *whole* string, even the stuff that's
				 * been processed.
				 */
				tabSize = 4;
			}
			str = emptyString(tabSize) ~ str[1 .. $];
			continue;
		} else {
			str = str[1 .. $];
			accum++;
			tabSize--;
			if (tabSize == 0) {
				tabSize = 4;
			}
		}
	}
	return str;
}

//! Create a string filled with spaces @p len characters long.
fn emptyString(len: size_t) string
{
	return uniformString(len, ' ');
}

//! Create a string `len` characters long, filled with `c` characters.
fn uniformString(len: size_t, c: char) string
{
	str := new char[](len);
	foreach (i; 0 .. len) {
		str[i] = c;
	}
	return cast(string)str;
}

//! Get the string representation of a paragraph.
fn paragraphToString(p: Paragraph) string
{
	ss: StringSink;
	foreach (child; p.children) {
		if (child.type != Type.Text) {
			continue;
		}
		text := child.toTextFast();
		ss.sink(text.str);
	}
	return ss.toString();
}

//! @Returns true if `c` is markdown punctuation.
fn markdownPunctuation(c: dchar) bool
{
	switch (c) {
	case '!', '#', '"', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.',
		 '/', ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', '`',
		 '{', '|', '}', '~':
		return true;
	default:
		return false;
	}
}

//! Turn consecutive whitespace into a single whitespace.
fn collapseWhitespace(str: string) string
{
	buf: char[];
	i: size_t;
	while (i < str.length) {
		c := decode(str, ref i);
		if (!isWhite(c)) {
			encode(ref buf, c);
			continue;
		}
		while (i < str.length && isWhite(c)) {
			c = decode(str, ref i);
		}
		encode(ref buf, ' ');
		if (!isWhite(c)) {
			encode(ref buf, c);
		}
	}
	return cast(string)buf;
}

//! Escape a string using markdown escape rules.
fn markdownEscape(str: string) string
{
	outStr: string;
	buf: char[];
	escapeBackslash := false;
	i: size_t;
	while (i < str.length) {
		c := decode(str, ref i);
		if (c != '\\' || i == str.length) {
			encode(ref buf, c);
			continue;
		}
		nextc := decode(str, ref i);
		if (nextc == '\\' || markdownPunctuation(nextc)) {
			encode(ref buf, nextc);
			continue;
		} else {
			encode(ref buf, c);
			encode(ref buf, nextc);
			continue;
		}
	}
	return cast(string)buf;
}

//! Build an AutoLink node.
fn makeAutoLink(url: string) Node
{
	par := buildParagraph();
	link := par.children.addLink(urlEscape(url), "");
	link.fromHtml = true;
	txt := link.children.addText(url);
	return par;
}

//! Build an EmailLink node.
fn makeEmailLink(url: string) Node
{
	par := buildParagraph();
	link := par.children.addLink("mailto:" ~ urlEscape(url), "");
	link.fromHtml = true;
	txt := link.children.addText(url);
	return par;
}

//! Build an AutoLinkNode.
fn makeStandaloneAutoLink(url: string) Node
{
	link := buildLink(urlEscape(url), "");
	link.fromHtml = true;
	txt := link.children.addText(url);
	return link;
}

//! @Returns `true` if `str` is an absolute URI, according to markdown rules.
fn isAbsoluteURI(str: string) bool
{
	// Empty urls, or schemes that don't start with a letter are not uris.
	i: size_t;
	if (i >= str.length || !isAlpha(str[i])) {
		return false;
	}

	// Parse the scheme.
	while (i < str.length && str[i] != ':') {
		if (!isAlphaNum(str[i]) && str[i] != '+' && str[i] != '-') {
			return false;
		}
		i++;
	}
	if (i >= str.length && str[i-1] == ':') {
		return true;
	}
	if (i >= str.length || str[i] != ':') {
		return false;
	}
	if (i == 1) {
		// Schemes are at least two characters long.
		return false;
	}
	i++;

	// Now check that the portion after the scheme is valid.
	if (i >= str.length) {
		return true;
	}
	while (i < str.length) {
		if (isWhite(str[i]) || str[i] == '<' || str[i] == '>') {
			return false;
		}
		i++;
	}
	return true;
}

/*! Percent encode a given url string.
 *  This isn't quite 'standard' in a few ways:
 *    - % is never encoded. The test suite has a nasty
 *      habit of passing a half encoded URL, saying
 *      'the spec doesn't actually care', but expecting
 *      it one way, so we don't encode it as %25.
 *    - [] are encoded. The RFC for this stuff states that
 *      the brackets are permissible, and do not need to be
 *      encoded, but CommonMark expects them to be.
 */
fn urlEscape(str: string) string
{
	buf: char[];

	changed := false;
	foreach (i, c: dchar; str) {
		switch (c) {
		case '!', '*', '\'', '(', ')', ';', ':', '@', '&', '=', '+',
			 '$', ',', '/', '?', '#', 'A', 'B', 'C', 'D',
			 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
			 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b',
			 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
			 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
			 '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '_',
			 '.', '~', '%':
			if (changed) {
				encode(ref buf, c);
			}
			break;
		default:
			if (!changed) {
				changed = true;
				buf = cast(char[])str[0 .. i];
			}
			tmpbuf: char[];
			encode(ref tmpbuf, c);
			foreach (_byte: char; tmpbuf) {
				buf ~= format("%%%X", cast(u8)_byte);
			}
			break;
		}
	}

	if (!changed) {
		return str;
	} else {
		return cast(string)buf;
	}
}

//! Escape HTML entities.
fn htmlEntityEscape(str: string) string
{
	buf: char[];
	i: size_t;
	readingEscape := false;
	decimalNumeric := false;
	decimalHex := false;
	escapeStart: size_t;
	lastI: size_t;
	while (i < str.length) {
		lastI = i;
		c := decode(str, ref i);
		if (!readingEscape && c != '&') {
			encode(ref buf, c);
			continue;
		}
		if (!readingEscape && c == '&') {
			readingEscape = true;
			escapeStart = lastI;
			continue;
		}
		assert(readingEscape);
		if (i - 2 == escapeStart && c == '#') {
			decimalNumeric = true;
		}
		if (i - 3 == escapeStart && decimalNumeric && (c == 'X' || c == 'x')) {
			decimalHex = true;
		}
		if (c == ';') {
			entityName := str[escapeStart .. i];
			replaced := "";
			if (decimalNumeric) {
				j: u32;
				numstr: string;
				if (decimalHex) {
					numstr = entityName[3 .. $-1];
				} else {
					numstr = entityName[2 .. $-1];
				}
				if (numstr != "") {
					try {
						j = cast(u32)toInt(numstr, decimalHex ? 16 : 10);
					} catch (ConvException) {
						j = 0xFFFD;
					}
					// @todo: how does one figure out what unicode character is invalid?
					if (j == 0 || j >= 0xE007F) {
						j = 0xFFFD;
					}
					encode(ref buf, j);
					readingEscape = false;
					decimalNumeric = false;
					decimalHex = false;
					continue;
				}
			} else {
				replaced = replaceEntity(entityName);
			}

			if (replaced != "") {
				foreach (k: dchar; replaced) {
					encode(ref buf, k);
				}
			} else {
				foreach (k: dchar; str[escapeStart .. i]) {
					encode(ref buf, k);
				}
			}
			readingEscape = false;
			decimalNumeric = false;
			decimalHex = false;
			continue;
		}
	}
	if (readingEscape) {
		foreach (k: dchar; str[escapeStart .. $]) {
			encode(ref buf, k);
		}
	}
	return cast(string)buf;
}

//! State for email validator.
enum EmailState
{
	BeforeAt,
	DomainStart,
	DomainBody,
}

//! @Returns `true` if `str` could be an email address.
fn isEmailAddress(str: string) bool
{
	state := EmailState.BeforeAt;
	foreach (i, c: dchar; str) {
		final switch (state) with (EmailState) {
		case BeforeAt:
			if (c == '@' && i != 0) {
				state = DomainStart;
				break;
			}
			if (!isAlphaNum(c) && c != '.' && c != '!' && c != '#' && c != '$' &&
				c != '%' && c != '&' && c != '\'' && c != '*' && c != '+' && c != '/' &&
				c != '=' && c != '?' && c != '^' && c != '_' && c != '`' && c != '{' &&
				c != '|' && c != '}' && c != '~' && c != '-') {
				return false;
			}
			break;
		case DomainStart:
			if (!isAlphaNum(c)) {
				return false;
			}
			state = DomainBody;
			break;
		case DomainBody:
			if (c == '.') {
				state = DomainStart;
				break;
			}
			if (!isAlphaNum(c) && c != '-') {
				return false;
			}
			break;
		}
	}
	return state == EmailState.DomainBody;
}

/*!
 * Is the string valid to be an HTML block?
 *
 * This is all a bit hacky, but a full HTML parser seems out of scope.
 * Basically these characters could be in a string or something, but if there's
 * not been whitespace, there's no way they could be valid.
 */
fn validBlockHtml(str: string) bool
{
	closing := str.length > 1 && str[1] == '/';
	hitWhite := false;
	foreach (c: dchar; str) {
		if (isWhite(c)) {
			hitWhite = true;
		}
		switch (c) {
		case '@', ':', '.':
			if (!hitWhite) {
				return false;
			}
			break;
		case '=':
			if (closing) {
				return false;
			}
			break;
		case '>':
			if (!hitWhite) {
				return true;
			}
			break;
		default:
			break;
		}
	}
	if (str.indexOf("#ref=") > 0) {
		return false;
	}
	if (str.indexOf("'title") > 0) {
		return false;
	}
	if (str.indexOf(`="\""`) > 0) {
		return false;
	}
	return true;
}

//! @Returns `true` if `str` is valid inline HTML.
fn validInlineHtml(str: string) bool
{
	if (!validBlockHtml(str)) {
		return false;
	}

	if (str.length > 4 && str[0 .. 4] == "<!--") {
		// A comment. Assume the parser did its job.
		return true;
	}

	if (str.length > 2 && str[0 .. 2] == "<!" || str[0 .. 2] == "<?") {
		// More special blocks. Again, trust the parser.
		return true;
	}

	if (str.length < 1 || str[0] != '<') {
		return false;
	}
	str = str[1 .. $];

	fn skipWhitespace()
	{
		while (str.length > 0 && isWhite(str[0])) {
			str = str[1 .. $];
		}
	}

	closingTag := false;
	if (str.length > 0 && str[0] == '/') {
		closingTag = true;
		str = str[1 .. $];
	}

	// Validate the name.
	if (str.length == 0 || !isAlpha(str[0])) {
		return false;
	} else {
		str = str[1 .. $];
	}
	while (str.length > 0 && (isAlphaNum(str[0]) || str[0] == '-')) {
		str = str[1 .. $];
	}
	if (str.length == 0 || (!isWhite(str[0]) && str[0] != '>' && str[0] != '/')) {
		return false;
	}

	if (closingTag) {
		skipWhitespace();
		return str.length == 1 && str[0] == '>';
	}

	dq := false;
	sq := false;

	while (str.length > 0 && str[0] != '>') {
		if (str[0] == '/' && (str.length != 2 || str[1] != '>')) {
			return false;
		}
		if (str[0] == '\'') {
			sq = !sq;
		}
		if (str[0] == '"') {
			dq = !dq;
		}
		if (str[0] == '#' && !sq && !dq) {
			return false;
		}
		str = str[1 .. $];
	}

	return true;  // todo: most things
}

//! Strip characters from a string hat are not allowed in image link titles.
fn altStringPresentation(str: string) string
{
	buf: char[];
	foreach (c: dchar; str) {
		switch (c) {
		case '!':
		case '*':
		case '[':
		case ']':
		case '<':
		case '>':
			break;
		default:
			encode(ref buf, c);
		}
	}
	return cast(string)buf;
}

//! Replace an HTML entity with the correct unicode character.
fn replaceEntity(str: string) string
{
	switch (str) {
	case "&lt": return "\u003C";
	case "&gt": return "\u003E";
	case "&LT": return "\u003C";
	case "&GT": return "\u003E";
	case "&yen": return "\u00A5";
	case "&xi;": return "\u03BE";
	case "&wr;": return "\u2240";
	case "&wp;": return "\u2118";
	case "&uml": return "\u00A8";
	case "&shy": return "\u00AD";
	case "&sc;": return "\u227B";
	case "&rx;": return "\u211E";
	case "&reg": return "\u00AE";
	case "&pr;": return "\u227A";
	case "&pm;": return "\u00B1";
	case "&pi;": return "\u03C0";
	case "&or;": return "\u2228";
	case "&oS;": return "\u24C8";
	case "&nu;": return "\u03BD";
	case "&not": return "\u00AC";
	case "&ni;": return "\u220B";
	case "&ne;": return "\u2260";
	case "&mu;": return "\u03BC";
	case "&mp;": return "\u2213";
	case "&lt;": return "\u003C";
	case "&ll;": return "\u226A";
	case "&lg;": return "\u2276";
	case "&le;": return "\u2264";
	case "&lE;": return "\u2266";
	case "&it;": return "\u2062";
	case "&in;": return "\u2208";
	case "&ii;": return "\u2148";
	case "&ic;": return "\u2063";
	case "&gt;": return "\u003E";
	case "&gl;": return "\u2277";
	case "&gg;": return "\u226B";
	case "&ge;": return "\u2265";
	case "&gE;": return "\u2267";
	case "&eth": return "\u00F0";
	case "&el;": return "\u2A99";
	case "&eg;": return "\u2A9A";
	case "&ee;": return "\u2147";
	case "&deg": return "\u00B0";
	case "&dd;": return "\u2146";
	case "&ap;": return "\u2248";
	case "&amp": return "\u0026";
	case "&af;": return "\u2061";
	case "&ac;": return "\u223E";
	case "&Xi;": return "\u039E";
	case "&Sc;": return "\u2ABC";
	case "&Re;": return "\u211C";
	case "&REG": return "\u00AE";
	case "&Pr;": return "\u2ABB";
	case "&Pi;": return "\u03A0";
	case "&Or;": return "\u2A54";
	case "&Nu;": return "\u039D";
	case "&Mu;": return "\u039C";
	case "&Lt;": return "\u226A";
	case "&Ll;": return "\u22D8";
	case "&LT;": return "\u003C";
	case "&Im;": return "\u2111";
	case "&Gt;": return "\u226B";
	case "&Gg;": return "\u22D9";
	case "&GT;": return "\u003E";
	case "&ETH": return "\u00D0";
	case "&DD;": return "\u2145";
	case "&AMP": return "\u0026";
	case "&zwj;": return "\u200D";
	case "&zcy;": return "\u0437";
	case "&yuml": return "\u00FF";
	case "&yen;": return "\u00A5";
	case "&ycy;": return "\u044B";
	case "&vee;": return "\u2228";
	case "&vcy;": return "\u0432";
	case "&uuml": return "\u00FC";
	case "&uml;": return "\u00A8";
	case "&ucy;": return "\u0443";
	case "&top;": return "\u22A4";
	case "&tcy;": return "\u0442";
	case "&tau;": return "\u03C4";
	case "&sup;": return "\u2283";
	case "&sup3": return "\u00B3";
	case "&sup2": return "\u00B2";
	case "&sup1": return "\u00B9";
	case "&sum;": return "\u2211";
	case "&sub;": return "\u2282";
	case "&squ;": return "\u25A1";
	case "&sol;": return "\u002F";
	case "&smt;": return "\u2AAA";
	case "&sim;": return "\u223C";
	case "&shy;": return "\u00AD";
	case "&sect": return "\u00A7";
	case "&scy;": return "\u0441";
	case "&sce;": return "\u2AB0";
	case "&scE;": return "\u2AB4";
	case "&rsh;": return "\u21B1";
	case "&rlm;": return "\u200F";
	case "&rho;": return "\u03C1";
	case "&reg;": return "\u00AE";
	case "&rcy;": return "\u0440";
	case "&quot": return "\u0022";
	case "&psi;": return "\u03C8";
	case "&pre;": return "\u2AAF";
	case "&prE;": return "\u2AB3";
	case "&piv;": return "\u03D6";
	case "&phi;": return "\u03C6";
	case "&pcy;": return "\u043F";
	case "&para": return "\u00B6";
	case "&par;": return "\u2225";
	case "&ouml": return "\u00F6";
	case "&orv;": return "\u2A5B";
	case "&ordm": return "\u00BA";
	case "&ordf": return "\u00AA";
	case "&ord;": return "\u2A5D";
	case "&olt;": return "\u29C0";
	case "&ohm;": return "\u03A9";
	case "&ogt;": return "\u29C1";
	case "&ocy;": return "\u043E";
	case "&num;": return "\u0023";
	case "&nsc;": return "\u2281";
	case "&npr;": return "\u2280";
	case "&not;": return "\u00AC";
	case "&nlt;": return "\u226E";
	case "&nle;": return "\u2270";
	case "&nlE;": return "\u2266\u0338";
	case "&niv;": return "\u220B";
	case "&nis;": return "\u22FC";
	case "&ngt;": return "\u226F";
	case "&nge;": return "\u2271";
	case "&ngE;": return "\u2267\u0338";
	case "&ncy;": return "\u043D";
	case "&nbsp": return "\u00A0";
	case "&nap;": return "\u2249";
	case "&nLt;": return "\u226A\u20D2";
	case "&nLl;": return "\u22D8\u0338";
	case "&nGt;": return "\u226B\u20D2";
	case "&nGg;": return "\u22D9\u0338";
	case "&mid;": return "\u2223";
	case "&mho;": return "\u2127";
	case "&mcy;": return "\u043C";
	case "&map;": return "\u21A6";
	case "&macr": return "\u00AF";
	case "&lsh;": return "\u21B0";
	case "&lrm;": return "\u200E";
	case "&loz;": return "\u25CA";
	case "&lne;": return "\u2A87";
	case "&lnE;": return "\u2268";
	case "&lgE;": return "\u2A91";
	case "&les;": return "\u2A7D";
	case "&leq;": return "\u2264";
	case "&leg;": return "\u22DA";
	case "&lcy;": return "\u043B";
	case "&lat;": return "\u2AAB";
	case "&lap;": return "\u2A85";
	case "&lEg;": return "\u2A8B";
	case "&kcy;": return "\u043A";
	case "&jcy;": return "\u0439";
	case "&iuml": return "\u00EF";
	case "&int;": return "\u222B";
	case "&iff;": return "\u21D4";
	case "&icy;": return "\u0438";
	case "&gne;": return "\u2A88";
	case "&gnE;": return "\u2269";
	case "&glj;": return "\u2AA4";
	case "&gla;": return "\u2AA5";
	case "&glE;": return "\u2A92";
	case "&ggg;": return "\u22D9";
	case "&ges;": return "\u2A7E";
	case "&geq;": return "\u2265";
	case "&gel;": return "\u22DB";
	case "&gcy;": return "\u0433";
	case "&gap;": return "\u2A86";
	case "&gEl;": return "\u2A8C";
	case "&fcy;": return "\u0444";
	case "&euml": return "\u00EB";
	case "&eth;": return "\u00F0";
	case "&eta;": return "\u03B7";
	case "&eng;": return "\u014B";
	case "&els;": return "\u2A95";
	case "&ell;": return "\u2113";
	case "&egs;": return "\u2A96";
	case "&ecy;": return "\u044D";
	case "&dot;": return "\u02D9";
	case "&div;": return "\u00F7";
	case "&die;": return "\u00A8";
	case "&deg;": return "\u00B0";
	case "&dcy;": return "\u0434";
	case "&cup;": return "\u222A";
	case "&copy": return "\u00A9";
	case "&cir;": return "\u25CB";
	case "&chi;": return "\u03C7";
	case "&cent": return "\u00A2";
	case "&cap;": return "\u2229";
	case "&bot;": return "\u22A5";
	case "&bne;": return "\u003D\u20E5";
	case "&bcy;": return "\u0431";
	case "&auml": return "\u00E4";
	case "&ast;": return "\u002A";
	case "&ape;": return "\u224A";
	case "&apE;": return "\u2A70";
	case "&ang;": return "\u2220";
	case "&and;": return "\u2227";
	case "&amp;": return "\u0026";
	case "&acy;": return "\u0430";
	case "&acd;": return "\u223F";
	case "&acE;": return "\u223E\u0333";
	case "&Zfr;": return "\u2128";
	case "&Zcy;": return "\u0417";
	case "&Ycy;": return "\u042B";
	case "&Vee;": return "\u22C1";
	case "&Vcy;": return "\u0412";
	case "&Uuml": return "\u00DC";
	case "&Ucy;": return "\u0423";
	case "&Tcy;": return "\u0422";
	case "&Tau;": return "\u03A4";
	case "&Tab;": return "\u0009";
	case "&Sup;": return "\u22D1";
	case "&Sum;": return "\u2211";
	case "&Sub;": return "\u22D0";
	case "&Scy;": return "\u0421";
	case "&Rsh;": return "\u21B1";
	case "&Rho;": return "\u03A1";
	case "&Rfr;": return "\u211C";
	case "&Rcy;": return "\u0420";
	case "&REG;": return "\u00AE";
	case "&QUOT": return "\u0022";
	case "&Psi;": return "\u03A8";
	case "&Phi;": return "\u03A6";
	case "&Pcy;": return "\u041F";
	case "&Ouml": return "\u00D6";
	case "&Ocy;": return "\u041E";
	case "&Not;": return "\u2AEC";
	case "&Ncy;": return "\u041D";
	case "&Mcy;": return "\u041C";
	case "&Map;": return "\u2905";
	case "&Lsh;": return "\u21B0";
	case "&Lcy;": return "\u041B";
	case "&Kcy;": return "\u041A";
	case "&Jcy;": return "\u0419";
	case "&Iuml": return "\u00CF";
	case "&Int;": return "\u222C";
	case "&Ifr;": return "\u2111";
	case "&Icy;": return "\u0418";
	case "&Hfr;": return "\u210C";
	case "&Hat;": return "\u005E";
	case "&Gcy;": return "\u0413";
	case "&Fcy;": return "\u0424";
	case "&Euml": return "\u00CB";
	case "&Eta;": return "\u0397";
	case "&Ecy;": return "\u042D";
	case "&ETH;": return "\u00D0";
	case "&ENG;": return "\u014A";
	case "&Dot;": return "\u00A8";
	case "&Del;": return "\u2207";
	case "&Dcy;": return "\u0414";
	case "&Cup;": return "\u22D3";
	case "&Chi;": return "\u03A7";
	case "&Cfr;": return "\u212D";
	case "&Cap;": return "\u22D2";
	case "&COPY": return "\u00A9";
	case "&Bcy;": return "\u0411";
	case "&Auml": return "\u00C4";
	case "&And;": return "\u2A53";
	case "&Acy;": return "\u0410";
	case "&AMP;": return "\u0026";
	case "&zwnj;": return "\u200C";
	case "&zhcy;": return "\u0436";
	case "&zeta;": return "\u03B6";
	case "&zdot;": return "\u017C";
	case "&yuml;": return "\u00FF";
	case "&yucy;": return "\u044E";
	case "&yicy;": return "\u0457";
	case "&yacy;": return "\u044F";
	case "&xvee;": return "\u22C1";
	case "&xnis;": return "\u22FB";
	case "&xmap;": return "\u27FC";
	case "&xcup;": return "\u22C3";
	case "&xcap;": return "\u22C2";
	case "&vert;": return "\u007C";
	case "&varr;": return "\u2195";
	case "&vBar;": return "\u2AE8";
	case "&vArr;": return "\u21D5";
	case "&uuml;": return "\u00FC";
	case "&utri;": return "\u25B5";
	case "&upsi;": return "\u03C5";
	case "&ucirc": return "\u00FB";
	case "&uarr;": return "\u2191";
	case "&uHar;": return "\u2963";
	case "&uArr;": return "\u21D1";
	case "&tscy;": return "\u0446";
	case "&trie;": return "\u225C";
	case "&tosa;": return "\u2929";
	case "&toea;": return "\u2928";
	case "&tint;": return "\u222D";
	case "&times": return "\u00D7";
	case "&thorn": return "\u00FE";
	case "&tdot;": return "\u20DB";
	case "&tbrk;": return "\u23B4";
	case "&szlig": return "\u00DF";
	case "&supe;": return "\u2287";
	case "&supE;": return "\u2AC6";
	case "&sup3;": return "\u00B3";
	case "&sup2;": return "\u00B2";
	case "&sup1;": return "\u00B9";
	case "&sung;": return "\u266A";
	case "&succ;": return "\u227B";
	case "&sube;": return "\u2286";
	case "&subE;": return "\u2AC5";
	case "&star;": return "\u2606";
	case "&squf;": return "\u25AA";
	case "&spar;": return "\u2225";
	case "&solb;": return "\u29C4";
	case "&smte;": return "\u2AAC";
	case "&smid;": return "\u2223";
	case "&siml;": return "\u2A9D";
	case "&simg;": return "\u2A9E";
	case "&sime;": return "\u2243";
	case "&shcy;": return "\u0448";
	case "&sext;": return "\u2736";
	case "&semi;": return "\u003B";
	case "&sect;": return "\u00A7";
	case "&sdot;": return "\u22C5";
	case "&scnE;": return "\u2AB6";
	case "&scap;": return "\u2AB8";
	case "&rtri;": return "\u25B9";
	case "&rsqb;": return "\u005D";
	case "&rpar;": return "\u0029";
	case "&ring;": return "\u02DA";
	case "&rhov;": return "\u03F1";
	case "&rect;": return "\u25AD";
	case "&real;": return "\u211C";
	case "&rdsh;": return "\u21B3";
	case "&rdca;": return "\u2937";
	case "&rcub;": return "\u007D";
	case "&rarr;": return "\u2192";
	case "&raquo": return "\u00BB";
	case "&rang;": return "\u27E9";
	case "&race;": return "\u223D\u0331";
	case "&rHar;": return "\u2964";
	case "&rArr;": return "\u21D2";
	case "&quot;": return "\u0022";
	case "&qint;": return "\u2A0C";
	case "&prop;": return "\u221D";
	case "&prod;": return "\u220F";
	case "&prnE;": return "\u2AB5";
	case "&prec;": return "\u227A";
	case "&prap;": return "\u2AB7";
	case "&pound": return "\u00A3";
	case "&plus;": return "\u002B";
	case "&phiv;": return "\u03D5";
	case "&perp;": return "\u22A5";
	case "&part;": return "\u2202";
	case "&para;": return "\u00B6";
	case "&ouml;": return "\u00F6";
	case "&osol;": return "\u2298";
	case "&oscr;": return "\u2134";
	case "&oror;": return "\u2A56";
	case "&ordm;": return "\u00BA";
	case "&ordf;": return "\u00AA";
	case "&opar;": return "\u29B7";
	case "&omid;": return "\u29B6";
	case "&oint;": return "\u222E";
	case "&ogon;": return "\u02DB";
	case "&odot;": return "\u2299";
	case "&odiv;": return "\u2A38";
	case "&ocirc": return "\u00F4";
	case "&ocir;": return "\u229A";
	case "&oast;": return "\u229B";
	case "&nvlt;": return "\u003C\u20D2";
	case "&nvle;": return "\u2264\u20D2";
	case "&nvgt;": return "\u003E\u20D2";
	case "&nvge;": return "\u2265\u20D2";
	case "&nvap;": return "\u224D\u20D2";
	case "&ntlg;": return "\u2278";
	case "&ntgl;": return "\u2279";
	case "&nsup;": return "\u2285";
	case "&nsub;": return "\u2284";
	case "&nsim;": return "\u2241";
	case "&nsce;": return "\u2AB0\u0338";
	case "&npre;": return "\u2AAF\u0338";
	case "&npar;": return "\u2226";
	case "&nmid;": return "\u2224";
	case "&nles;": return "\u2A7D\u0338";
	case "&nleq;": return "\u2270";
	case "&nldr;": return "\u2025";
	case "&njcy;": return "\u045A";
	case "&nisd;": return "\u22FA";
	case "&ngtr;": return "\u226F";
	case "&nges;": return "\u2A7E\u0338";
	case "&ngeq;": return "\u2271";
	case "&ncup;": return "\u2A42";
	case "&ncap;": return "\u2A43";
	case "&nbsp;": return "\u00A0";
	case "&napE;": return "\u2A70\u0338";
	case "&nang;": return "\u2220\u20D2";
	case "&nLtv;": return "\u226A\u0338";
	case "&nGtv;": return "\u226B\u0338";
	case "&mldr;": return "\u2026";
	case "&mlcp;": return "\u2ADB";
	case "&micro": return "\u00B5";
	case "&malt;": return "\u2720";
	case "&male;": return "\u2642";
	case "&macr;": return "\u00AF";
	case "&lvnE;": return "\u2268\uFE00";
	case "&ltri;": return "\u25C3";
	case "&ltcc;": return "\u2AA6";
	case "&lsqb;": return "\u005B";
	case "&lsim;": return "\u2272";
	case "&lpar;": return "\u0028";
	case "&lozf;": return "\u29EB";
	case "&lneq;": return "\u2A87";
	case "&lnap;": return "\u2A89";
	case "&ljcy;": return "\u0459";
	case "&lesg;": return "\u22DA\uFE00";
	case "&leqq;": return "\u2266";
	case "&ldsh;": return "\u21B2";
	case "&ldca;": return "\u2936";
	case "&lcub;": return "\u007B";
	case "&late;": return "\u2AAD";
	case "&larr;": return "\u2190";
	case "&laquo": return "\u00AB";
	case "&lang;": return "\u27E8";
	case "&lHar;": return "\u2962";
	case "&lArr;": return "\u21D0";
	case "&kjcy;": return "\u045C";
	case "&khcy;": return "\u0445";
	case "&iuml;": return "\u00EF";
	case "&isin;": return "\u2208";
	case "&iota;": return "\u03B9";
	case "&iocy;": return "\u0451";
	case "&imof;": return "\u22B7";
	case "&iexcl": return "\u00A1";
	case "&iecy;": return "\u0435";
	case "&icirc": return "\u00EE";
	case "&hbar;": return "\u210F";
	case "&harr;": return "\u2194";
	case "&half;": return "\u00BD";
	case "&hArr;": return "\u21D4";
	case "&gvnE;": return "\u2269\uFE00";
	case "&gtcc;": return "\u2AA7";
	case "&gsim;": return "\u2273";
	case "&gscr;": return "\u210A";
	case "&gneq;": return "\u2A88";
	case "&gnap;": return "\u2A8A";
	case "&gjcy;": return "\u0453";
	case "&gesl;": return "\u22DB\uFE00";
	case "&geqq;": return "\u2267";
	case "&gdot;": return "\u0121";
	case "&fork;": return "\u22D4";
	case "&fnof;": return "\u0192";
	case "&flat;": return "\u266D";
	case "&excl;": return "\u0021";
	case "&euro;": return "\u20AC";
	case "&euml;": return "\u00EB";
	case "&esim;": return "\u2242";
	case "&escr;": return "\u212F";
	case "&epsi;": return "\u03B5";
	case "&epar;": return "\u22D5";
	case "&ensp;": return "\u2002";
	case "&emsp;": return "\u2003";
	case "&edot;": return "\u0117";
	case "&ecirc": return "\u00EA";
	case "&ecir;": return "\u2256";
	case "&eDot;": return "\u2251";
	case "&dzcy;": return "\u045F";
	case "&dtri;": return "\u25BF";
	case "&dsol;": return "\u29F6";
	case "&dscy;": return "\u0455";
	case "&djcy;": return "\u0452";
	case "&diam;": return "\u22C4";
	case "&dash;": return "\u2010";
	case "&darr;": return "\u2193";
	case "&dHar;": return "\u2965";
	case "&dArr;": return "\u21D3";
	case "&cups;": return "\u222A\uFE00";
	case "&csup;": return "\u2AD0";
	case "&csub;": return "\u2ACF";
	case "&copy;": return "\u00A9";
	case "&cong;": return "\u2245";
	case "&comp;": return "\u2201";
	case "&cire;": return "\u2257";
	case "&circ;": return "\u02C6";
	case "&cirE;": return "\u29C3";
	case "&chcy;": return "\u0447";
	case "&cent;": return "\u00A2";
	case "&cedil": return "\u00B8";
	case "&cdot;": return "\u010B";
	case "&caps;": return "\u2229\uFE00";
	case "&bump;": return "\u224E";
	case "&bull;": return "\u2022";
	case "&bsol;": return "\u005C";
	case "&bsim;": return "\u223D";
	case "&boxv;": return "\u2502";
	case "&boxh;": return "\u2500";
	case "&boxV;": return "\u2551";
	case "&boxH;": return "\u2550";
	case "&bnot;": return "\u2310";
	case "&beth;": return "\u2136";
	case "&beta;": return "\u03B2";
	case "&bbrk;": return "\u23B5";
	case "&bNot;": return "\u2AED";
	case "&auml;": return "\u00E4";
	case "&aring": return "\u00E5";
	case "&apos;": return "\u0027";
	case "&apid;": return "\u224B";
	case "&ange;": return "\u29A4";
	case "&andv;": return "\u2A5A";
	case "&andd;": return "\u2A5C";
	case "&aelig": return "\u00E6";
	case "&acute": return "\u00B4";
	case "&acirc": return "\u00E2";
	case "&Zopf;": return "\u2124";
	case "&Zeta;": return "\u0396";
	case "&Zdot;": return "\u017B";
	case "&ZHcy;": return "\u0416";
	case "&Yuml;": return "\u0178";
	case "&YUcy;": return "\u042E";
	case "&YIcy;": return "\u0407";
	case "&YAcy;": return "\u042F";
	case "&Vert;": return "\u2016";
	case "&Vbar;": return "\u2AEB";
	case "&Uuml;": return "\u00DC";
	case "&Upsi;": return "\u03D2";
	case "&Ucirc": return "\u00DB";
	case "&Uarr;": return "\u219F";
	case "&TScy;": return "\u0426";
	case "&THORN": return "\u00DE";
	case "&Star;": return "\u22C6";
	case "&Sqrt;": return "\u221A";
	case "&SHcy;": return "\u0428";
	case "&Rscr;": return "\u211B";
	case "&Ropf;": return "\u211D";
	case "&Rarr;": return "\u21A0";
	case "&Rang;": return "\u27EB";
	case "&Qopf;": return "\u211A";
	case "&QUOT;": return "\u0022";
	case "&Popf;": return "\u2119";
	case "&Ouml;": return "\u00D6";
	case "&Ocirc": return "\u00D4";
	case "&Nopf;": return "\u2115";
	case "&NJcy;": return "\u040A";
	case "&Mscr;": return "\u2133";
	case "&Lscr;": return "\u2112";
	case "&Larr;": return "\u219E";
	case "&Lang;": return "\u27EA";
	case "&LJcy;": return "\u0409";
	case "&KJcy;": return "\u040C";
	case "&KHcy;": return "\u0425";
	case "&Iuml;": return "\u00CF";
	case "&Iscr;": return "\u2110";
	case "&Iota;": return "\u0399";
	case "&Idot;": return "\u0130";
	case "&Icirc": return "\u00CE";
	case "&IOcy;": return "\u0401";
	case "&IEcy;": return "\u0415";
	case "&Hscr;": return "\u210B";
	case "&Hopf;": return "\u210D";
	case "&Gdot;": return "\u0120";
	case "&GJcy;": return "\u0403";
	case "&Fscr;": return "\u2131";
	case "&Euml;": return "\u00CB";
	case "&Esim;": return "\u2A73";
	case "&Escr;": return "\u2130";
	case "&Edot;": return "\u0116";
	case "&Ecirc": return "\u00CA";
	case "&Darr;": return "\u21A1";
	case "&DZcy;": return "\u040F";
	case "&DScy;": return "\u0405";
	case "&DJcy;": return "\u0402";
	case "&Copf;": return "\u2102";
	case "&Cdot;": return "\u010A";
	case "&COPY;": return "\u00A9";
	case "&CHcy;": return "\u0427";
	case "&Bscr;": return "\u212C";
	case "&Beta;": return "\u0392";
	case "&Barv;": return "\u2AE7";
	case "&Auml;": return "\u00C4";
	case "&Aring": return "\u00C5";
	case "&Acirc": return "\u00C2";
	case "&AElig": return "\u00C6";
	case "&ycirc;": return "\u0177";
	case "&yacute": return "\u00FD";
	case "&xutri;": return "\u25B3";
	case "&xrarr;": return "\u27F6";
	case "&xrArr;": return "\u27F9";
	case "&xodot;": return "\u2A00";
	case "&xlarr;": return "\u27F5";
	case "&xlArr;": return "\u27F8";
	case "&xharr;": return "\u27F7";
	case "&xhArr;": return "\u27FA";
	case "&xdtri;": return "\u25BD";
	case "&xcirc;": return "\u25EF";
	case "&wedge;": return "\u2227";
	case "&wcirc;": return "\u0175";
	case "&vrtri;": return "\u22B3";
	case "&vprop;": return "\u221D";
	case "&vnsup;": return "\u2283\u20D2";
	case "&vnsub;": return "\u2282\u20D2";
	case "&vltri;": return "\u22B2";
	case "&veeeq;": return "\u225A";
	case "&vdash;": return "\u22A2";
	case "&varpi;": return "\u03D6";
	case "&vDash;": return "\u22A8";
	case "&vBarv;": return "\u2AE9";
	case "&uuarr;": return "\u21C8";
	case "&utrif;": return "\u25B4";
	case "&utdot;": return "\u22F0";
	case "&urtri;": return "\u25F9";
	case "&uring;": return "\u016F";
	case "&upsih;": return "\u03D2";
	case "&uplus;": return "\u228E";
	case "&uogon;": return "\u0173";
	case "&umacr;": return "\u016B";
	case "&ultri;": return "\u25F8";
	case "&uhblk;": return "\u2580";
	case "&uharr;": return "\u21BE";
	case "&uharl;": return "\u21BF";
	case "&ugrave": return "\u00F9";
	case "&udhar;": return "\u296E";
	case "&udarr;": return "\u21C5";
	case "&ucirc;": return "\u00FB";
	case "&ubrcy;": return "\u045E";
	case "&uacute": return "\u00FA";
	case "&twixt;": return "\u226C";
	case "&tshcy;": return "\u045B";
	case "&trisb;": return "\u29CD";
	case "&trade;": return "\u2122";
	case "&times;": return "\u00D7";
	case "&tilde;": return "\u02DC";
	case "&thorn;": return "\u00FE";
	case "&thkap;": return "\u2248";
	case "&theta;": return "\u03B8";
	case "&szlig;": return "\u00DF";
	case "&swarr;": return "\u2199";
	case "&swArr;": return "\u21D9";
	case "&supne;": return "\u228B";
	case "&supnE;": return "\u2ACC";
	case "&subne;": return "\u228A";
	case "&subnE;": return "\u2ACB";
	case "&strns;": return "\u00AF";
	case "&starf;": return "\u2605";
	case "&srarr;": return "\u2192";
	case "&sqsup;": return "\u2290";
	case "&sqsub;": return "\u228F";
	case "&sqcup;": return "\u2294";
	case "&sqcap;": return "\u2293";
	case "&smtes;": return "\u2AAC\uFE00";
	case "&smile;": return "\u2323";
	case "&slarr;": return "\u2190";
	case "&simne;": return "\u2246";
	case "&simlE;": return "\u2A9F";
	case "&simgE;": return "\u2AA0";
	case "&simeq;": return "\u2243";
	case "&sigma;": return "\u03C3";
	case "&sharp;": return "\u266F";
	case "&setmn;": return "\u2216";
	case "&searr;": return "\u2198";
	case "&seArr;": return "\u21D8";
	case "&sdote;": return "\u2A66";
	case "&sdotb;": return "\u22A1";
	case "&scsim;": return "\u227F";
	case "&scnap;": return "\u2ABA";
	case "&scirc;": return "\u015D";
	case "&sccue;": return "\u227D";
	case "&sbquo;": return "\u201A";
	case "&rtrif;": return "\u25B8";
	case "&rtrie;": return "\u22B5";
	case "&rsquo;": return "\u2019";
	case "&rrarr;": return "\u21C9";
	case "&ropar;": return "\u2986";
	case "&robrk;": return "\u27E7";
	case "&roarr;": return "\u21FE";
	case "&roang;": return "\u27ED";
	case "&rnmid;": return "\u2AEE";
	case "&rlhar;": return "\u21CC";
	case "&rlarr;": return "\u21C4";
	case "&rharu;": return "\u21C0";
	case "&rhard;": return "\u21C1";
	case "&reals;": return "\u211D";
	case "&rdquo;": return "\u201D";
	case "&rceil;": return "\u2309";
	case "&rbrke;": return "\u298C";
	case "&rbbrk;": return "\u2773";
	case "&rbarr;": return "\u290D";
	case "&ratio;": return "\u2236";
	case "&rarrw;": return "\u219D";
	case "&rarrc;": return "\u2933";
	case "&rarrb;": return "\u21E5";
	case "&raquo;": return "\u00BB";
	case "&range;": return "\u29A5";
	case "&rangd;": return "\u2992";
	case "&radic;": return "\u221A";
	case "&rBarr;": return "\u290F";
	case "&rAarr;": return "\u21DB";
	case "&quest;": return "\u003F";
	case "&prsim;": return "\u227E";
	case "&prnap;": return "\u2AB9";
	case "&prime;": return "\u2032";
	case "&prcue;": return "\u227C";
	case "&pound;": return "\u00A3";
	case "&plusmn": return "\u00B1";
	case "&pluse;": return "\u2A72";
	case "&plusb;": return "\u229E";
	case "&phone;": return "\u260E";
	case "&parsl;": return "\u2AFD";
	case "&ovbar;": return "\u233D";
	case "&otilde": return "\u00F5";
	case "&oslash": return "\u00F8";
	case "&order;": return "\u2134";
	case "&orarr;": return "\u21BB";
	case "&oplus;": return "\u2295";
	case "&operp;": return "\u29B9";
	case "&omega;": return "\u03C9";
	case "&omacr;": return "\u014D";
	case "&oline;": return "\u203E";
	case "&olcir;": return "\u29BE";
	case "&olarr;": return "\u21BA";
	case "&ohbar;": return "\u29B5";
	case "&ograve": return "\u00F2";
	case "&ofcir;": return "\u29BF";
	case "&oelig;": return "\u0153";
	case "&odash;": return "\u229D";
	case "&ocirc;": return "\u00F4";
	case "&oacute": return "\u00F3";
	case "&nwarr;": return "\u2196";
	case "&nwArr;": return "\u21D6";
	case "&nvsim;": return "\u223C\u20D2";
	case "&numsp;": return "\u2007";
	case "&ntilde": return "\u00F1";
	case "&nsupe;": return "\u2289";
	case "&nsupE;": return "\u2AC6\u0338";
	case "&nsucc;": return "\u2281";
	case "&nsube;": return "\u2288";
	case "&nsubE;": return "\u2AC5\u0338";
	case "&nspar;": return "\u2226";
	case "&nsmid;": return "\u2224";
	case "&nsime;": return "\u2244";
	case "&nrtri;": return "\u22EB";
	case "&nrarr;": return "\u219B";
	case "&nrArr;": return "\u21CF";
	case "&nprec;": return "\u2280";
	case "&npart;": return "\u2202\u0338";
	case "&notni;": return "\u220C";
	case "&notin;": return "\u2209";
	case "&nltri;": return "\u22EA";
	case "&nlsim;": return "\u2274";
	case "&nless;": return "\u226E";
	case "&nleqq;": return "\u2266\u0338";
	case "&nlarr;": return "\u219A";
	case "&nlArr;": return "\u21CD";
	case "&nhpar;": return "\u2AF2";
	case "&nharr;": return "\u21AE";
	case "&nhArr;": return "\u21CE";
	case "&ngsim;": return "\u2275";
	case "&ngeqq;": return "\u2267\u0338";
	case "&nesim;": return "\u2242\u0338";
	case "&nedot;": return "\u2250\u0338";
	case "&nearr;": return "\u2197";
	case "&neArr;": return "\u21D7";
	case "&ndash;": return "\u2013";
	case "&ncong;": return "\u2247";
	case "&nbump;": return "\u224E\u0338";
	case "&natur;": return "\u266E";
	case "&napos;": return "\u0149";
	case "&napid;": return "\u224B\u0338";
	case "&nabla;": return "\u2207";
	case "&mumap;": return "\u22B8";
	case "&minus;": return "\u2212";
	case "&middot": return "\u00B7";
	case "&micro;": return "\u00B5";
	case "&mdash;": return "\u2014";
	case "&mDDot;": return "\u223A";
	case "&ltrif;": return "\u25C2";
	case "&ltrie;": return "\u22B4";
	case "&ltdot;": return "\u22D6";
	case "&ltcir;": return "\u2A79";
	case "&lsquo;": return "\u2018";
	case "&lsimg;": return "\u2A8F";
	case "&lsime;": return "\u2A8D";
	case "&lrtri;": return "\u22BF";
	case "&lrhar;": return "\u21CB";
	case "&lrarr;": return "\u21C6";
	case "&lopar;": return "\u2985";
	case "&lobrk;": return "\u27E6";
	case "&loarr;": return "\u21FD";
	case "&loang;": return "\u27EC";
	case "&lnsim;": return "\u22E6";
	case "&lneqq;": return "\u2268";
	case "&lltri;": return "\u25FA";
	case "&llarr;": return "\u21C7";
	case "&lhblk;": return "\u2584";
	case "&lharu;": return "\u21BC";
	case "&lhard;": return "\u21BD";
	case "&lescc;": return "\u2AA8";
	case "&ldquo;": return "\u201C";
	case "&lceil;": return "\u2308";
	case "&lbrke;": return "\u298B";
	case "&lbbrk;": return "\u2772";
	case "&lbarr;": return "\u290C";
	case "&lates;": return "\u2AAD\uFE00";
	case "&larrb;": return "\u21E4";
	case "&laquo;": return "\u00AB";
	case "&langd;": return "\u2991";
	case "&lBarr;": return "\u290E";
	case "&lAarr;": return "\u21DA";
	case "&kappa;": return "\u03BA";
	case "&jukcy;": return "\u0454";
	case "&jmath;": return "\u0237";
	case "&jcirc;": return "\u0135";
	case "&iukcy;": return "\u0456";
	case "&isinv;": return "\u2208";
	case "&isins;": return "\u22F4";
	case "&isinE;": return "\u22F9";
	case "&iquest": return "\u00BF";
	case "&iprod;": return "\u2A3C";
	case "&iogon;": return "\u012F";
	case "&infin;": return "\u221E";
	case "&imped;": return "\u01B5";
	case "&imath;": return "\u0131";
	case "&image;": return "\u2111";
	case "&imacr;": return "\u012B";
	case "&ijlig;": return "\u0133";
	case "&iiota;": return "\u2129";
	case "&iiint;": return "\u222D";
	case "&igrave": return "\u00EC";
	case "&iexcl;": return "\u00A1";
	case "&icirc;": return "\u00EE";
	case "&iacute": return "\u00ED";
	case "&hoarr;": return "\u21FF";
	case "&hcirc;": return "\u0125";
	case "&harrw;": return "\u21AD";
	case "&gtdot;": return "\u22D7";
	case "&gtcir;": return "\u2A7A";
	case "&gsiml;": return "\u2A90";
	case "&gsime;": return "\u2A8E";
	case "&grave;": return "\u0060";
	case "&gnsim;": return "\u22E7";
	case "&gneqq;": return "\u2269";
	case "&gimel;": return "\u2137";
	case "&gescc;": return "\u2AA9";
	case "&gcirc;": return "\u011D";
	case "&gamma;": return "\u03B3";
	case "&frown;": return "\u2322";
	case "&frasl;": return "\u2044";
	case "&frac34": return "\u00BE";
	case "&frac14": return "\u00BC";
	case "&frac12": return "\u00BD";
	case "&forkv;": return "\u2AD9";
	case "&fltns;": return "\u25B1";
	case "&fllig;": return "\uFB02";
	case "&fjlig;": return "\u0066\u006A";
	case "&filig;": return "\uFB01";
	case "&fflig;": return "\uFB00";
	case "&exist;": return "\u2203";
	case "&esdot;": return "\u2250";
	case "&erarr;": return "\u2971";
	case "&erDot;": return "\u2253";
	case "&equiv;": return "\u2261";
	case "&eqsim;": return "\u2242";
	case "&epsiv;": return "\u03F5";
	case "&eplus;": return "\u2A71";
	case "&eogon;": return "\u0119";
	case "&empty;": return "\u2205";
	case "&emacr;": return "\u0113";
	case "&egrave": return "\u00E8";
	case "&efDot;": return "\u2252";
	case "&ecirc;": return "\u00EA";
	case "&eacute": return "\u00E9";
	case "&eDDot;": return "\u2A77";
	case "&duhar;": return "\u296F";
	case "&duarr;": return "\u21F5";
	case "&dtrif;": return "\u25BE";
	case "&dtdot;": return "\u22F1";
	case "&doteq;": return "\u2250";
	case "&divide": return "\u00F7";
	case "&disin;": return "\u22F2";
	case "&diams;": return "\u2666";
	case "&dharr;": return "\u21C2";
	case "&dharl;": return "\u21C3";
	case "&delta;": return "\u03B4";
	case "&ddarr;": return "\u21CA";
	case "&dblac;": return "\u02DD";
	case "&dashv;": return "\u22A3";
	case "&cwint;": return "\u2231";
	case "&cuwed;": return "\u22CF";
	case "&cuvee;": return "\u22CE";
	case "&curren": return "\u00A4";
	case "&cupor;": return "\u2A45";
	case "&cuesc;": return "\u22DF";
	case "&cuepr;": return "\u22DE";
	case "&ctdot;": return "\u22EF";
	case "&csupe;": return "\u2AD2";
	case "&csube;": return "\u2AD1";
	case "&cross;": return "\u2717";
	case "&crarr;": return "\u21B5";
	case "&comma;": return "\u002C";
	case "&colon;": return "\u003A";
	case "&clubs;": return "\u2663";
	case "&check;": return "\u2713";
	case "&cedil;": return "\u00B8";
	case "&ccups;": return "\u2A4C";
	case "&ccirc;": return "\u0109";
	case "&ccedil": return "\u00E7";
	case "&ccaps;": return "\u2A4D";
	case "&caron;": return "\u02C7";
	case "&caret;": return "\u2041";
	case "&bumpe;": return "\u224F";
	case "&bumpE;": return "\u2AAE";
	case "&bsolb;": return "\u29C5";
	case "&bsime;": return "\u22CD";
	case "&bsemi;": return "\u204F";
	case "&brvbar": return "\u00A6";
	case "&breve;": return "\u02D8";
	case "&boxvr;": return "\u251C";
	case "&boxvl;": return "\u2524";
	case "&boxvh;": return "\u253C";
	case "&boxvR;": return "\u255E";
	case "&boxvL;": return "\u2561";
	case "&boxvH;": return "\u256A";
	case "&boxur;": return "\u2514";
	case "&boxul;": return "\u2518";
	case "&boxuR;": return "\u2558";
	case "&boxuL;": return "\u255B";
	case "&boxhu;": return "\u2534";
	case "&boxhd;": return "\u252C";
	case "&boxhU;": return "\u2568";
	case "&boxhD;": return "\u2565";
	case "&boxdr;": return "\u250C";
	case "&boxdl;": return "\u2510";
	case "&boxdR;": return "\u2552";
	case "&boxdL;": return "\u2555";
	case "&boxVr;": return "\u255F";
	case "&boxVl;": return "\u2562";
	case "&boxVh;": return "\u256B";
	case "&boxVR;": return "\u2560";
	case "&boxVL;": return "\u2563";
	case "&boxVH;": return "\u256C";
	case "&boxUr;": return "\u2559";
	case "&boxUl;": return "\u255C";
	case "&boxUR;": return "\u255A";
	case "&boxUL;": return "\u255D";
	case "&boxHu;": return "\u2567";
	case "&boxHd;": return "\u2564";
	case "&boxHU;": return "\u2569";
	case "&boxHD;": return "\u2566";
	case "&boxDr;": return "\u2553";
	case "&boxDl;": return "\u2556";
	case "&boxDR;": return "\u2554";
	case "&boxDL;": return "\u2557";
	case "&block;": return "\u2588";
	case "&blk34;": return "\u2593";
	case "&blk14;": return "\u2591";
	case "&blk12;": return "\u2592";
	case "&blank;": return "\u2423";
	case "&bepsi;": return "\u03F6";
	case "&bdquo;": return "\u201E";
	case "&bcong;": return "\u224C";
	case "&awint;": return "\u2A11";
	case "&atilde": return "\u00E3";
	case "&asymp;": return "\u2248";
	case "&aring;": return "\u00E5";
	case "&aogon;": return "\u0105";
	case "&angst;": return "\u00C5";
	case "&angrt;": return "\u221F";
	case "&angle;": return "\u2220";
	case "&amalg;": return "\u2A3F";
	case "&amacr;": return "\u0101";
	case "&alpha;": return "\u03B1";
	case "&aleph;": return "\u2135";
	case "&agrave": return "\u00E0";
	case "&aelig;": return "\u00E6";
	case "&acute;": return "\u00B4";
	case "&acirc;": return "\u00E2";
	case "&aacute": return "\u00E1";
	case "&Ycirc;": return "\u0176";
	case "&Yacute": return "\u00DD";
	case "&Wedge;": return "\u22C0";
	case "&Wcirc;": return "\u0174";
	case "&Vdash;": return "\u22A9";
	case "&VDash;": return "\u22AB";
	case "&Uring;": return "\u016E";
	case "&UpTee;": return "\u22A5";
	case "&Uogon;": return "\u0172";
	case "&Union;": return "\u22C3";
	case "&Umacr;": return "\u016A";
	case "&Ugrave": return "\u00D9";
	case "&Ucirc;": return "\u00DB";
	case "&Ubrcy;": return "\u040E";
	case "&Uacute": return "\u00DA";
	case "&Tilde;": return "\u223C";
	case "&Theta;": return "\u0398";
	case "&TSHcy;": return "\u040B";
	case "&TRADE;": return "\u2122";
	case "&THORN;": return "\u00DE";
	case "&Sigma;": return "\u03A3";
	case "&Scirc;": return "\u015C";
	case "&RBarr;": return "\u2910";
	case "&Prime;": return "\u2033";
	case "&Otilde": return "\u00D5";
	case "&Oslash": return "\u00D8";
	case "&Omega;": return "\u03A9";
	case "&Omacr;": return "\u014C";
	case "&Ograve": return "\u00D2";
	case "&Ocirc;": return "\u00D4";
	case "&Oacute": return "\u00D3";
	case "&OElig;": return "\u0152";
	case "&Ntilde": return "\u00D1";
	case "&Kappa;": return "\u039A";
	case "&Jukcy;": return "\u0404";
	case "&Jcirc;": return "\u0134";
	case "&Iukcy;": return "\u0406";
	case "&Iogon;": return "\u012E";
	case "&Imacr;": return "\u012A";
	case "&Igrave": return "\u00CC";
	case "&Icirc;": return "\u00CE";
	case "&Iacute": return "\u00CD";
	case "&IJlig;": return "\u0132";
	case "&Hcirc;": return "\u0124";
	case "&Hacek;": return "\u02C7";
	case "&Gcirc;": return "\u011C";
	case "&Gamma;": return "\u0393";
	case "&Equal;": return "\u2A75";
	case "&Eogon;": return "\u0118";
	case "&Emacr;": return "\u0112";
	case "&Egrave": return "\u00C8";
	case "&Ecirc;": return "\u00CA";
	case "&Eacute": return "\u00C9";
	case "&Delta;": return "\u0394";
	case "&Dashv;": return "\u2AE4";
	case "&Cross;": return "\u2A2F";
	case "&Colon;": return "\u2237";
	case "&Ccirc;": return "\u0108";
	case "&Ccedil": return "\u00C7";
	case "&Breve;": return "\u02D8";
	case "&Atilde": return "\u00C3";
	case "&Aring;": return "\u00C5";
	case "&Aogon;": return "\u0104";
	case "&Amacr;": return "\u0100";
	case "&Alpha;": return "\u0391";
	case "&Agrave": return "\u00C0";
	case "&Acirc;": return "\u00C2";
	case "&Aacute": return "\u00C1";
	case "&AElig;": return "\u00C6";
	case "&zeetrf;": return "\u2128";
	case "&zcaron;": return "\u017E";
	case "&zacute;": return "\u017A";
	case "&yacute;": return "\u00FD";
	case "&xwedge;": return "\u22C0";
	case "&xuplus;": return "\u2A04";
	case "&xsqcup;": return "\u2A06";
	case "&xotime;": return "\u2A02";
	case "&xoplus;": return "\u2A01";
	case "&wreath;": return "\u2240";
	case "&weierp;": return "\u2118";
	case "&wedgeq;": return "\u2259";
	case "&wedbar;": return "\u2A5F";
	case "&vsupne;": return "\u228B\uFE00";
	case "&vsupnE;": return "\u2ACC\uFE00";
	case "&vsubne;": return "\u228A\uFE00";
	case "&vsubnE;": return "\u2ACB\uFE00";
	case "&verbar;": return "\u007C";
	case "&vellip;": return "\u22EE";
	case "&veebar;": return "\u22BB";
	case "&varrho;": return "\u03F1";
	case "&varphi;": return "\u03D5";
	case "&vangrt;": return "\u299C";
	case "&utilde;": return "\u0169";
	case "&urcrop;": return "\u230E";
	case "&urcorn;": return "\u231D";
	case "&ulcrop;": return "\u230F";
	case "&ulcorn;": return "\u231C";
	case "&ugrave;": return "\u00F9";
	case "&ufisht;": return "\u297E";
	case "&udblac;": return "\u0171";
	case "&ubreve;": return "\u016D";
	case "&uacute;": return "\u00FA";
	case "&tstrok;": return "\u0167";
	case "&tridot;": return "\u25EC";
	case "&tprime;": return "\u2034";
	case "&topcir;": return "\u2AF1";
	case "&topbot;": return "\u2336";
	case "&timesd;": return "\u2A30";
	case "&timesb;": return "\u22A0";
	case "&thksim;": return "\u223C";
	case "&thinsp;": return "\u2009";
	case "&thetav;": return "\u03D1";
	case "&there4;": return "\u2234";
	case "&telrec;": return "\u2315";
	case "&tcedil;": return "\u0163";
	case "&tcaron;": return "\u0165";
	case "&target;": return "\u2316";
	case "&swnwar;": return "\u292A";
	case "&swarhk;": return "\u2926";
	case "&supsup;": return "\u2AD6";
	case "&supsub;": return "\u2AD4";
	case "&supsim;": return "\u2AC8";
	case "&supset;": return "\u2283";
	case "&supdot;": return "\u2ABE";
	case "&succeq;": return "\u2AB0";
	case "&subsup;": return "\u2AD3";
	case "&subsub;": return "\u2AD5";
	case "&subsim;": return "\u2AC7";
	case "&subset;": return "\u2282";
	case "&subdot;": return "\u2ABD";
	case "&sstarf;": return "\u22C6";
	case "&ssmile;": return "\u2323";
	case "&ssetmn;": return "\u2216";
	case "&squarf;": return "\u25AA";
	case "&square;": return "\u25A1";
	case "&sqsupe;": return "\u2292";
	case "&sqsube;": return "\u2291";
	case "&sqcups;": return "\u2294\uFE00";
	case "&sqcaps;": return "\u2293\uFE00";
	case "&spades;": return "\u2660";
	case "&solbar;": return "\u233F";
	case "&softcy;": return "\u044C";
	case "&smashp;": return "\u2A33";
	case "&simdot;": return "\u2A6A";
	case "&sigmav;": return "\u03C2";
	case "&sigmaf;": return "\u03C2";
	case "&shchcy;": return "\u0449";
	case "&sfrown;": return "\u2322";
	case "&seswar;": return "\u2929";
	case "&searhk;": return "\u2925";
	case "&scnsim;": return "\u22E9";
	case "&scedil;": return "\u015F";
	case "&scaron;": return "\u0161";
	case "&sacute;": return "\u015B";
	case "&rtimes;": return "\u22CA";
	case "&rthree;": return "\u22CC";
	case "&rsquor;": return "\u2019";
	case "&rsaquo;": return "\u203A";
	case "&rpargt;": return "\u2994";
	case "&roplus;": return "\u2A2E";
	case "&rmoust;": return "\u23B1";
	case "&rharul;": return "\u296C";
	case "&rfloor;": return "\u230B";
	case "&rfisht;": return "\u297D";
	case "&rdquor;": return "\u201D";
	case "&rcedil;": return "\u0157";
	case "&rcaron;": return "\u0159";
	case "&rbrack;": return "\u005D";
	case "&rbrace;": return "\u007D";
	case "&ratail;": return "\u291A";
	case "&rarrtl;": return "\u21A3";
	case "&rarrpl;": return "\u2945";
	case "&rarrlp;": return "\u21AC";
	case "&rarrhk;": return "\u21AA";
	case "&rarrfs;": return "\u291E";
	case "&rarrap;": return "\u2975";
	case "&rangle;": return "\u27E9";
	case "&racute;": return "\u0155";
	case "&rAtail;": return "\u291C";
	case "&qprime;": return "\u2057";
	case "&puncsp;": return "\u2008";
	case "&prurel;": return "\u22B0";
	case "&propto;": return "\u221D";
	case "&prnsim;": return "\u22E8";
	case "&primes;": return "\u2119";
	case "&preceq;": return "\u2AAF";
	case "&plusmn;": return "\u00B1";
	case "&plusdu;": return "\u2A25";
	case "&plusdo;": return "\u2214";
	case "&plankv;": return "\u210F";
	case "&planck;": return "\u210F";
	case "&phmmat;": return "\u2133";
	case "&permil;": return "\u2030";
	case "&period;": return "\u002E";
	case "&percnt;": return "\u0025";
	case "&parsim;": return "\u2AF3";
	case "&otimes;": return "\u2297";
	case "&otilde;": return "\u00F5";
	case "&oslash;": return "\u00F8";
	case "&origof;": return "\u22B6";
	case "&ominus;": return "\u2296";
	case "&ograve;": return "\u00F2";
	case "&odsold;": return "\u29BC";
	case "&odblac;": return "\u0151";
	case "&oacute;": return "\u00F3";
	case "&nwnear;": return "\u2927";
	case "&nwarhk;": return "\u2923";
	case "&nvrArr;": return "\u2903";
	case "&nvlArr;": return "\u2902";
	case "&nvdash;": return "\u22AC";
	case "&nvHarr;": return "\u2904";
	case "&nvDash;": return "\u22AD";
	case "&numero;": return "\u2116";
	case "&ntilde;": return "\u00F1";
	case "&nsimeq;": return "\u2244";
	case "&nsccue;": return "\u22E1";
	case "&nrtrie;": return "\u22ED";
	case "&nrarrw;": return "\u219D\u0338";
	case "&nrarrc;": return "\u2933\u0338";
	case "&nprcue;": return "\u22E0";
	case "&nparsl;": return "\u2AFD\u20E5";
	case "&notinE;": return "\u22F9\u0338";
	case "&nltrie;": return "\u22EC";
	case "&nexist;": return "\u2204";
	case "&nesear;": return "\u2928";
	case "&nequiv;": return "\u2262";
	case "&nearhk;": return "\u2924";
	case "&ncedil;": return "\u0146";
	case "&ncaron;": return "\u0148";
	case "&nbumpe;": return "\u224F\u0338";
	case "&nacute;": return "\u0144";
	case "&nVdash;": return "\u22AE";
	case "&nVDash;": return "\u22AF";
	case "&mstpos;": return "\u223E";
	case "&models;": return "\u22A7";
	case "&mnplus;": return "\u2213";
	case "&minusd;": return "\u2238";
	case "&minusb;": return "\u229F";
	case "&middot;": return "\u00B7";
	case "&midcir;": return "\u2AF0";
	case "&midast;": return "\u002A";
	case "&mcomma;": return "\u2A29";
	case "&marker;": return "\u25AE";
	case "&mapsto;": return "\u21A6";
	case "&ltrPar;": return "\u2996";
	case "&ltlarr;": return "\u2976";
	case "&ltimes;": return "\u22C9";
	case "&lthree;": return "\u22CB";
	case "&lstrok;": return "\u0142";
	case "&lsquor;": return "\u201A";
	case "&lsaquo;": return "\u2039";
	case "&lrhard;": return "\u296D";
	case "&lparlt;": return "\u2993";
	case "&lowbar;": return "\u005F";
	case "&lowast;": return "\u2217";
	case "&loplus;": return "\u2A2D";
	case "&lmoust;": return "\u23B0";
	case "&lmidot;": return "\u0140";
	case "&llhard;": return "\u296B";
	case "&lharul;": return "\u296A";
	case "&lfloor;": return "\u230A";
	case "&lfisht;": return "\u297C";
	case "&lesges;": return "\u2A93";
	case "&lesdot;": return "\u2A7F";
	case "&ldquor;": return "\u201E";
	case "&lcedil;": return "\u013C";
	case "&lcaron;": return "\u013E";
	case "&lbrack;": return "\u005B";
	case "&lbrace;": return "\u007B";
	case "&latail;": return "\u2919";
	case "&larrtl;": return "\u21A2";
	case "&larrpl;": return "\u2939";
	case "&larrlp;": return "\u21AB";
	case "&larrhk;": return "\u21A9";
	case "&larrfs;": return "\u291D";
	case "&langle;": return "\u27E8";
	case "&lambda;": return "\u03BB";
	case "&lagran;": return "\u2112";
	case "&lacute;": return "\u013A";
	case "&lAtail;": return "\u291B";
	case "&kgreen;": return "\u0138";
	case "&kcedil;": return "\u0137";
	case "&kappav;": return "\u03F0";
	case "&jsercy;": return "\u0458";
	case "&itilde;": return "\u0129";
	case "&isinsv;": return "\u22F3";
	case "&iquest;": return "\u00BF";
	case "&intcal;": return "\u22BA";
	case "&inodot;": return "\u0131";
	case "&incare;": return "\u2105";
	case "&iinfin;": return "\u29DC";
	case "&iiiint;": return "\u2A0C";
	case "&igrave;": return "\u00EC";
	case "&iacute;": return "\u00ED";
	case "&hyphen;": return "\u2010";
	case "&hybull;": return "\u2043";
	case "&hstrok;": return "\u0127";
	case "&hslash;": return "\u210F";
	case "&horbar;": return "\u2015";
	case "&homtht;": return "\u223B";
	case "&hercon;": return "\u22B9";
	case "&hellip;": return "\u2026";
	case "&hearts;": return "\u2665";
	case "&hardcy;": return "\u044A";
	case "&hamilt;": return "\u210B";
	case "&hairsp;": return "\u200A";
	case "&gtrsim;": return "\u2273";
	case "&gtrdot;": return "\u22D7";
	case "&gtrarr;": return "\u2978";
	case "&gtlPar;": return "\u2995";
	case "&gesles;": return "\u2A94";
	case "&gesdot;": return "\u2A80";
	case "&gbreve;": return "\u011F";
	case "&gammad;": return "\u03DD";
	case "&gacute;": return "\u01F5";
	case "&frac78;": return "\u215E";
	case "&frac58;": return "\u215D";
	case "&frac56;": return "\u215A";
	case "&frac45;": return "\u2158";
	case "&frac38;": return "\u215C";
	case "&frac35;": return "\u2157";
	case "&frac34;": return "\u00BE";
	case "&frac25;": return "\u2156";
	case "&frac23;": return "\u2154";
	case "&frac18;": return "\u215B";
	case "&frac16;": return "\u2159";
	case "&frac15;": return "\u2155";
	case "&frac14;": return "\u00BC";
	case "&frac13;": return "\u2153";
	case "&frac12;": return "\u00BD";
	case "&forall;": return "\u2200";
	case "&ffllig;": return "\uFB04";
	case "&ffilig;": return "\uFB03";
	case "&female;": return "\u2640";
	case "&equest;": return "\u225F";
	case "&equals;": return "\u003D";
	case "&eqcirc;": return "\u2256";
	case "&eparsl;": return "\u29E3";
	case "&emsp14;": return "\u2005";
	case "&emsp13;": return "\u2004";
	case "&emptyv;": return "\u2205";
	case "&elsdot;": return "\u2A97";
	case "&egsdot;": return "\u2A98";
	case "&egrave;": return "\u00E8";
	case "&ecolon;": return "\u2255";
	case "&ecaron;": return "\u011B";
	case "&easter;": return "\u2A6E";
	case "&eacute;": return "\u00E9";
	case "&dstrok;": return "\u0111";
	case "&drcrop;": return "\u230C";
	case "&drcorn;": return "\u231F";
	case "&dollar;": return "\u0024";
	case "&dlcrop;": return "\u230D";
	case "&dlcorn;": return "\u231E";
	case "&divonx;": return "\u22C7";
	case "&divide;": return "\u00F7";
	case "&dfisht;": return "\u297F";
	case "&dcaron;": return "\u010F";
	case "&daleth;": return "\u2138";
	case "&dagger;": return "\u2020";
	case "&cylcty;": return "\u232D";
	case "&curren;": return "\u00A4";
	case "&curarr;": return "\u21B7";
	case "&cupdot;": return "\u228D";
	case "&cupcup;": return "\u2A4A";
	case "&cupcap;": return "\u2A46";
	case "&cularr;": return "\u21B6";
	case "&copysr;": return "\u2117";
	case "&coprod;": return "\u2210";
	case "&conint;": return "\u222E";
	case "&compfn;": return "\u2218";
	case "&commat;": return "\u0040";
	case "&colone;": return "\u2254";
	case "&cirmid;": return "\u2AEF";
	case "&circeq;": return "\u2257";
	case "&ccedil;": return "\u00E7";
	case "&ccaron;": return "\u010D";
	case "&capdot;": return "\u2A40";
	case "&capcup;": return "\u2A47";
	case "&capcap;": return "\u2A4B";
	case "&capand;": return "\u2A44";
	case "&cacute;": return "\u0107";
	case "&bumpeq;": return "\u224F";
	case "&bullet;": return "\u2022";
	case "&brvbar;": return "\u00A6";
	case "&bprime;": return "\u2035";
	case "&boxbox;": return "\u29C9";
	case "&bowtie;": return "\u22C8";
	case "&bottom;": return "\u22A5";
	case "&bkarow;": return "\u290D";
	case "&bigvee;": return "\u22C1";
	case "&bigcup;": return "\u22C3";
	case "&bigcap;": return "\u22C2";
	case "&bernou;": return "\u212C";
	case "&becaus;": return "\u2235";
	case "&barwed;": return "\u2305";
	case "&barvee;": return "\u22BD";
	case "&atilde;": return "\u00E3";
	case "&approx;": return "\u2248";
	case "&apacir;": return "\u2A6F";
	case "&angsph;": return "\u2222";
	case "&angmsd;": return "\u2221";
	case "&andand;": return "\u2A55";
	case "&agrave;": return "\u00E0";
	case "&abreve;": return "\u0103";
	case "&aacute;": return "\u00E1";
	case "&Zcaron;": return "\u017D";
	case "&Zacute;": return "\u0179";
	case "&Yacute;": return "\u00DD";
	case "&Vvdash;": return "\u22AA";
	case "&Verbar;": return "\u2016";
	case "&Vdashl;": return "\u2AE6";
	case "&Utilde;": return "\u0168";
	case "&Ugrave;": return "\u00D9";
	case "&Udblac;": return "\u0170";
	case "&Ubreve;": return "\u016C";
	case "&Uacute;": return "\u00DA";
	case "&Tstrok;": return "\u0166";
	case "&Tcedil;": return "\u0162";
	case "&Tcaron;": return "\u0164";
	case "&Supset;": return "\u22D1";
	case "&Subset;": return "\u22D0";
	case "&Square;": return "\u25A1";
	case "&Scedil;": return "\u015E";
	case "&Scaron;": return "\u0160";
	case "&Sacute;": return "\u015A";
	case "&SOFTcy;": return "\u042C";
	case "&SHCHcy;": return "\u0429";
	case "&Rcedil;": return "\u0156";
	case "&Rcaron;": return "\u0158";
	case "&Rarrtl;": return "\u2916";
	case "&Racute;": return "\u0154";
	case "&Otimes;": return "\u2A37";
	case "&Otilde;": return "\u00D5";
	case "&Oslash;": return "\u00D8";
	case "&Ograve;": return "\u00D2";
	case "&Odblac;": return "\u0150";
	case "&Oacute;": return "\u00D3";
	case "&Ntilde;": return "\u00D1";
	case "&Ncedil;": return "\u0145";
	case "&Ncaron;": return "\u0147";
	case "&Nacute;": return "\u0143";
	case "&Lstrok;": return "\u0141";
	case "&Lmidot;": return "\u013F";
	case "&Lcedil;": return "\u013B";
	case "&Lcaron;": return "\u013D";
	case "&Lambda;": return "\u039B";
	case "&Lacute;": return "\u0139";
	case "&Kcedil;": return "\u0136";
	case "&Jsercy;": return "\u0408";
	case "&Itilde;": return "\u0128";
	case "&Igrave;": return "\u00CC";
	case "&Iacute;": return "\u00CD";
	case "&Hstrok;": return "\u0126";
	case "&HARDcy;": return "\u042A";
	case "&Gcedil;": return "\u0122";
	case "&Gbreve;": return "\u011E";
	case "&Gammad;": return "\u03DC";
	case "&ForAll;": return "\u2200";
	case "&Exists;": return "\u2203";
	case "&Egrave;": return "\u00C8";
	case "&Ecaron;": return "\u011A";
	case "&Eacute;": return "\u00C9";
	case "&Dstrok;": return "\u0110";
	case "&DotDot;": return "\u20DC";
	case "&Dcaron;": return "\u010E";
	case "&Dagger;": return "\u2021";
	case "&CupCap;": return "\u224D";
	case "&Conint;": return "\u222F";
	case "&Colone;": return "\u2A74";
	case "&Ccedil;": return "\u00C7";
	case "&Ccaron;": return "\u010C";
	case "&Cacute;": return "\u0106";
	case "&Bumpeq;": return "\u224E";
	case "&Barwed;": return "\u2306";
	case "&Atilde;": return "\u00C3";
	case "&Assign;": return "\u2254";
	case "&Agrave;": return "\u00C0";
	case "&Abreve;": return "\u0102";
	case "&Aacute;": return "\u00C1";
	case "&zigrarr;": return "\u21DD";
	case "&vzigzag;": return "\u299A";
	case "&uwangle;": return "\u29A7";
	case "&upsilon;": return "\u03C5";
	case "&uparrow;": return "\u2191";
	case "&tritime;": return "\u2A3B";
	case "&triplus;": return "\u2A39";
	case "&topfork;": return "\u2ADA";
	case "&swarrow;": return "\u2199";
	case "&supplus;": return "\u2AC0";
	case "&supmult;": return "\u2AC2";
	case "&suplarr;": return "\u297B";
	case "&suphsub;": return "\u2AD7";
	case "&suphsol;": return "\u27C9";
	case "&supedot;": return "\u2AC4";
	case "&supdsub;": return "\u2AD8";
	case "&succsim;": return "\u227F";
	case "&subrarr;": return "\u2979";
	case "&subplus;": return "\u2ABF";
	case "&submult;": return "\u2AC1";
	case "&subedot;": return "\u2AC3";
	case "&simrarr;": return "\u2972";
	case "&simplus;": return "\u2A24";
	case "&searrow;": return "\u2198";
	case "&ruluhar;": return "\u2968";
	case "&rotimes;": return "\u2A35";
	case "&realine;": return "\u211B";
	case "&rdldhar;": return "\u2969";
	case "&rbrkslu;": return "\u2990";
	case "&rbrksld;": return "\u298E";
	case "&rarrsim;": return "\u2974";
	case "&rarrbfs;": return "\u2920";
	case "&questeq;": return "\u225F";
	case "&quatint;": return "\u2A16";
	case "&precsim;": return "\u227E";
	case "&plustwo;": return "\u2A27";
	case "&plussim;": return "\u2A26";
	case "&pluscir;": return "\u2A22";
	case "&planckh;": return "\u210E";
	case "&pertenk;": return "\u2031";
	case "&orslope;": return "\u2A57";
	case "&orderof;": return "\u2134";
	case "&omicron;": return "\u03BF";
	case "&olcross;": return "\u29BB";
	case "&nwarrow;": return "\u2196";
	case "&nvrtrie;": return "\u22B5\u20D2";
	case "&nvltrie;": return "\u22B4\u20D2";
	case "&nvinfin;": return "\u29DE";
	case "&nsupset;": return "\u2283\u20D2";
	case "&nsucceq;": return "\u2AB0\u0338";
	case "&nsubset;": return "\u2282\u20D2";
	case "&nsqsupe;": return "\u22E3";
	case "&nsqsube;": return "\u22E2";
	case "&npreceq;": return "\u2AAF\u0338";
	case "&npolint;": return "\u2A14";
	case "&notnivc;": return "\u22FD";
	case "&notnivb;": return "\u22FE";
	case "&notniva;": return "\u220C";
	case "&notinvc;": return "\u22F6";
	case "&notinvb;": return "\u22F7";
	case "&notinva;": return "\u2209";
	case "&nexists;": return "\u2204";
	case "&nearrow;": return "\u2197";
	case "&natural;": return "\u266E";
	case "&napprox;": return "\u2249";
	case "&minusdu;": return "\u2A2A";
	case "&maltese;": return "\u2720";
	case "&luruhar;": return "\u2966";
	case "&ltquest;": return "\u2A7B";
	case "&lozenge;": return "\u25CA";
	case "&lotimes;": return "\u2A34";
	case "&lesssim;": return "\u2272";
	case "&lessgtr;": return "\u2276";
	case "&lessdot;": return "\u22D6";
	case "&lesdoto;": return "\u2A81";
	case "&ldrdhar;": return "\u2967";
	case "&lbrkslu;": return "\u298D";
	case "&lbrksld;": return "\u298F";
	case "&larrsim;": return "\u2973";
	case "&larrbfs;": return "\u291F";
	case "&isindot;": return "\u22F5";
	case "&intprod;": return "\u2A3C";
	case "&harrcir;": return "\u2948";
	case "&gtrless;": return "\u2277";
	case "&gtquest;": return "\u2A7C";
	case "&gesdoto;": return "\u2A82";
	case "&equivDD;": return "\u2A78";
	case "&eqcolon;": return "\u2255";
	case "&epsilon;": return "\u03B5";
	case "&dwangle;": return "\u29A6";
	case "&dotplus;": return "\u2214";
	case "&digamma;": return "\u03DD";
	case "&diamond;": return "\u22C4";
	case "&demptyv;": return "\u29B1";
	case "&ddotseq;": return "\u2A77";
	case "&ddagger;": return "\u2021";
	case "&dbkarow;": return "\u290F";
	case "&curarrm;": return "\u293C";
	case "&cularrp;": return "\u293D";
	case "&cudarrr;": return "\u2935";
	case "&cudarrl;": return "\u2938";
	case "&congdot;": return "\u2A6D";
	case "&coloneq;": return "\u2254";
	case "&cirscir;": return "\u29C2";
	case "&cemptyv;": return "\u29B2";
	case "&ccupssm;": return "\u2A50";
	case "&boxplus;": return "\u229E";
	case "&bnequiv;": return "\u2261\u20E5";
	case "&bigstar;": return "\u2605";
	case "&bigodot;": return "\u2A00";
	case "&bigcirc;": return "\u25EF";
	case "&between;": return "\u226C";
	case "&bemptyv;": return "\u29B0";
	case "&because;": return "\u2235";
	case "&backsim;": return "\u223D";
	case "&asympeq;": return "\u224D";
	case "&angzarr;": return "\u237C";
	case "&angrtvb;": return "\u22BE";
	case "&alefsym;": return "\u2135";
	case "&Upsilon;": return "\u03A5";
	case "&Uparrow;": return "\u21D1";
	case "&UpArrow;": return "\u2191";
	case "&Product;": return "\u220F";
	case "&OverBar;": return "\u203E";
	case "&Omicron;": return "\u039F";
	case "&NotLess;": return "\u226E";
	case "&NoBreak;": return "\u2060";
	case "&NewLine;": return "\u000A";
	case "&LeftTee;": return "\u22A3";
	case "&Implies;": return "\u21D2";
	case "&Epsilon;": return "\u0395";
	case "&Element;": return "\u2208";
	case "&DownTee;": return "\u22A4";
	case "&Diamond;": return "\u22C4";
	case "&Cedilla;": return "\u00B8";
	case "&Cconint;": return "\u2230";
	case "&Cayleys;": return "\u212D";
	case "&Because;": return "\u2235";
	case "&vartheta;": return "\u03D1";
	case "&varsigma;": return "\u03C2";
	case "&varkappa;": return "\u03F0";
	case "&urcorner;": return "\u231D";
	case "&ulcorner;": return "\u231C";
	case "&trpezium;": return "\u23E2";
	case "&triminus;": return "\u2A3A";
	case "&triangle;": return "\u25B5";
	case "&timesbar;": return "\u2A31";
	case "&thicksim;": return "\u223C";
	case "&thetasym;": return "\u03D1";
	case "&supseteq;": return "\u2287";
	case "&succnsim;": return "\u22E9";
	case "&succneqq;": return "\u2AB6";
	case "&subseteq;": return "\u2286";
	case "&sqsupset;": return "\u2290";
	case "&sqsubset;": return "\u228F";
	case "&smeparsl;": return "\u29E4";
	case "&shortmid;": return "\u2223";
	case "&setminus;": return "\u2216";
	case "&scpolint;": return "\u2A13";
	case "&rtriltri;": return "\u29CE";
	case "&rppolint;": return "\u2A12";
	case "&realpart;": return "\u211C";
	case "&raemptyv;": return "\u29B3";
	case "&profsurf;": return "\u2313";
	case "&profline;": return "\u2312";
	case "&profalar;": return "\u232E";
	case "&precnsim;": return "\u22E8";
	case "&precneqq;": return "\u2AB5";
	case "&pointint;": return "\u2A15";
	case "&plusacir;": return "\u2A23";
	case "&parallel;": return "\u2225";
	case "&otimesas;": return "\u2A36";
	case "&notindot;": return "\u22F5\u0338";
	case "&ncongdot;": return "\u2A6D\u0338";
	case "&naturals;": return "\u2115";
	case "&multimap;": return "\u22B8";
	case "&mapstoup;": return "\u21A5";
	case "&lurdshar;": return "\u294A";
	case "&lrcorner;": return "\u231F";
	case "&lnapprox;": return "\u2A89";
	case "&llcorner;": return "\u231E";
	case "&lesdotor;": return "\u2A83";
	case "&leqslant;": return "\u2A7D";
	case "&ldrushar;": return "\u294B";
	case "&laemptyv;": return "\u29B4";
	case "&intlarhk;": return "\u2A17";
	case "&intercal;": return "\u22BA";
	case "&integers;": return "\u2124";
	case "&infintie;": return "\u29DD";
	case "&imagpart;": return "\u2111";
	case "&imagline;": return "\u2110";
	case "&hkswarow;": return "\u2926";
	case "&hksearow;": return "\u2925";
	case "&gnapprox;": return "\u2A8A";
	case "&gesdotol;": return "\u2A84";
	case "&geqslant;": return "\u2A7E";
	case "&fpartint;": return "\u2A0D";
	case "&eqvparsl;": return "\u29E5";
	case "&emptyset;": return "\u2205";
	case "&elinters;": return "\u23E7";
	case "&dzigrarr;": return "\u27FF";
	case "&drbkarow;": return "\u2910";
	case "&dotminus;": return "\u2238";
	case "&doteqdot;": return "\u2251";
	case "&cwconint;": return "\u2232";
	case "&curlyvee;": return "\u22CE";
	case "&cupbrcap;": return "\u2A48";
	case "&clubsuit;": return "\u2663";
	case "&cirfnint;": return "\u2A10";
	case "&circledS;": return "\u24C8";
	case "&circledR;": return "\u00AE";
	case "&capbrcup;": return "\u2A49";
	case "&bsolhsub;": return "\u27C8";
	case "&boxtimes;": return "\u22A0";
	case "&boxminus;": return "\u229F";
	case "&bigwedge;": return "\u22C0";
	case "&biguplus;": return "\u2A04";
	case "&bigsqcup;": return "\u2A06";
	case "&bigoplus;": return "\u2A01";
	case "&bbrktbrk;": return "\u23B6";
	case "&barwedge;": return "\u2305";
	case "&backcong;": return "\u224C";
	case "&awconint;": return "\u2233";
	case "&approxeq;": return "\u224A";
	case "&angrtvbd;": return "\u299D";
	case "&angmsdah;": return "\u29AF";
	case "&angmsdag;": return "\u29AE";
	case "&angmsdaf;": return "\u29AD";
	case "&angmsdae;": return "\u29AC";
	case "&angmsdad;": return "\u29AB";
	case "&angmsdac;": return "\u29AA";
	case "&angmsdab;": return "\u29A9";
	case "&angmsdaa;": return "\u29A8";
	case "&andslope;": return "\u2A58";
	case "&UnderBar;": return "\u005F";
	case "&Uarrocir;": return "\u2949";
	case "&Superset;": return "\u2283";
	case "&SuchThat;": return "\u220B";
	case "&Succeeds;": return "\u227B";
	case "&RightTee;": return "\u22A2";
	case "&Precedes;": return "\u227A";
	case "&PartialD;": return "\u2202";
	case "&NotTilde;": return "\u2241";
	case "&NotEqual;": return "\u2260";
	case "&LessLess;": return "\u2AA1";
	case "&Integral;": return "\u222B";
	case "&DotEqual;": return "\u2250";
	case "&DDotrahd;": return "\u2911";
	case "&varpropto;": return "\u221D";
	case "&triangleq;": return "\u225C";
	case "&therefore;": return "\u2234";
	case "&supsetneq;": return "\u228B";
	case "&supseteqq;": return "\u2AC6";
	case "&subsetneq;": return "\u228A";
	case "&subseteqq;": return "\u2AC5";
	case "&spadesuit;": return "\u2660";
	case "&rationals;": return "\u211A";
	case "&pitchfork;": return "\u22D4";
	case "&nsupseteq;": return "\u2289";
	case "&nsubseteq;": return "\u2288";
	case "&nshortmid;": return "\u2224";
	case "&nparallel;": return "\u2226";
	case "&nleqslant;": return "\u2A7D\u0338";
	case "&ngeqslant;": return "\u2A7E\u0338";
	case "&lvertneqq;": return "\u2268\uFE00";
	case "&lesseqgtr;": return "\u22DA";
	case "&leftarrow;": return "\u2190";
	case "&heartsuit;": return "\u2665";
	case "&gvertneqq;": return "\u2269\uFE00";
	case "&gtreqless;": return "\u22DB";
	case "&gtrapprox;": return "\u2A86";
	case "&downarrow;": return "\u2193";
	case "&dotsquare;": return "\u22A1";
	case "&complexes;": return "\u2102";
	case "&checkmark;": return "\u2713";
	case "&centerdot;": return "\u00B7";
	case "&bigotimes;": return "\u2A02";
	case "&backsimeq;": return "\u22CD";
	case "&backprime;": return "\u2035";
	case "&UnionPlus;": return "\u228E";
	case "&TripleDot;": return "\u20DB";
	case "&ThinSpace;": return "\u2009";
	case "&Therefore;": return "\u2234";
	case "&PlusMinus;": return "\u00B1";
	case "&OverBrace;": return "\u23DE";
	case "&NotSubset;": return "\u2282\u20D2";
	case "&NotExists;": return "\u2204";
	case "&NotCupCap;": return "\u226D";
	case "&MinusPlus;": return "\u2213";
	case "&Mellintrf;": return "\u2133";
	case "&LessTilde;": return "\u2272";
	case "&Leftarrow;": return "\u21D0";
	case "&LeftFloor;": return "\u230A";
	case "&LeftArrow;": return "\u2190";
	case "&HumpEqual;": return "\u224F";
	case "&Downarrow;": return "\u21D3";
	case "&DownBreve;": return "\u0311";
	case "&DownArrow;": return "\u2193";
	case "&DoubleDot;": return "\u00A8";
	case "&Coproduct;": return "\u2210";
	case "&Congruent;": return "\u2261";
	case "&CircleDot;": return "\u2299";
	case "&CenterDot;": return "\u00B7";
	case "&Backslash;": return "\u2216";
	case "&varnothing;": return "\u2205";
	case "&varepsilon;": return "\u03F5";
	case "&upuparrows;": return "\u21C8";
	case "&supsetneqq;": return "\u2ACC";
	case "&succapprox;": return "\u2AB8";
	case "&subsetneqq;": return "\u2ACB";
	case "&sqsupseteq;": return "\u2292";
	case "&sqsubseteq;": return "\u2291";
	case "&rmoustache;": return "\u23B1";
	case "&rightarrow;": return "\u2192";
	case "&precapprox;": return "\u2AB7";
	case "&nsupseteqq;": return "\u2AC6\u0338";
	case "&nsubseteqq;": return "\u2AC5\u0338";
	case "&nleftarrow;": return "\u219A";
	case "&nLeftarrow;": return "\u21CD";
	case "&mapstoleft;": return "\u21A4";
	case "&mapstodown;": return "\u21A7";
	case "&longmapsto;": return "\u27FC";
	case "&lmoustache;": return "\u23B0";
	case "&lesseqqgtr;": return "\u2A8B";
	case "&lessapprox;": return "\u2A85";
	case "&gtreqqless;": return "\u2A8C";
	case "&eqslantgtr;": return "\u2A96";
	case "&curlywedge;": return "\u22CF";
	case "&complement;": return "\u2201";
	case "&circledast;": return "\u229B";
	case "&UpTeeArrow;": return "\u21A5";
	case "&UpArrowBar;": return "\u2912";
	case "&UnderBrace;": return "\u23DF";
	case "&TildeTilde;": return "\u2248";
	case "&TildeEqual;": return "\u2243";
	case "&ThickSpace;": return "\u205F\u200A";
	case "&Rightarrow;": return "\u21D2";
	case "&RightFloor;": return "\u230B";
	case "&RightArrow;": return "\u2192";
	case "&Proportion;": return "\u2237";
	case "&NotGreater;": return "\u226F";
	case "&NotElement;": return "\u2209";
	case "&Lleftarrow;": return "\u21DA";
	case "&LeftVector;": return "\u21BC";
	case "&Laplacetrf;": return "\u2112";
	case "&ImaginaryI;": return "\u2148";
	case "&Fouriertrf;": return "\u2131";
	case "&EqualTilde;": return "\u2242";
	case "&CirclePlus;": return "\u2295";
	case "&Bernoullis;": return "\u212C";
	case "&updownarrow;": return "\u2195";
	case "&thickapprox;": return "\u2248";
	case "&succnapprox;": return "\u2ABA";
	case "&succcurlyeq;": return "\u227D";
	case "&straightphi;": return "\u03D5";
	case "&quaternions;": return "\u210D";
	case "&precnapprox;": return "\u2AB9";
	case "&preccurlyeq;": return "\u227C";
	case "&nrightarrow;": return "\u219B";
	case "&nRightarrow;": return "\u21CF";
	case "&expectation;": return "\u2130";
	case "&eqslantless;": return "\u2A95";
	case "&diamondsuit;": return "\u2666";
	case "&curlyeqsucc;": return "\u22DF";
	case "&curlyeqprec;": return "\u22DE";
	case "&circleddash;": return "\u229D";
	case "&circledcirc;": return "\u229A";
	case "&blacksquare;": return "\u25AA";
	case "&backepsilon;": return "\u03F6";
	case "&VerticalBar;": return "\u2223";
	case "&Updownarrow;": return "\u21D5";
	case "&UpDownArrow;": return "\u2195";
	case "&SubsetEqual;": return "\u2286";
	case "&SquareUnion;": return "\u2294";
	case "&SmallCircle;": return "\u2218";
	case "&RuleDelayed;": return "\u29F4";
	case "&Rrightarrow;": return "\u21DB";
	case "&RightVector;": return "\u21C0";
	case "&OverBracket;": return "\u23B4";
	case "&NotSuperset;": return "\u2283\u20D2";
	case "&NotSucceeds;": return "\u2281";
	case "&NotPrecedes;": return "\u2280";
	case "&NotLessLess;": return "\u226A\u0338";
	case "&MediumSpace;": return "\u205F";
	case "&LessGreater;": return "\u2276";
	case "&LeftCeiling;": return "\u2308";
	case "&GreaterLess;": return "\u2277";
	case "&Equilibrium;": return "\u21CC";
	case "&CircleTimes;": return "\u2297";
	case "&CircleMinus;": return "\u2296";
	case "&varsupsetneq;": return "\u228B\uFE00";
	case "&varsubsetneq;": return "\u228A\uFE00";
	case "&triangleleft;": return "\u25C3";
	case "&triangledown;": return "\u25BF";
	case "&risingdotseq;": return "\u2253";
	case "&exponentiale;": return "\u2147";
	case "&blacklozenge;": return "\u29EB";
	case "&VerticalLine;": return "\u007C";
	case "&UnderBracket;": return "\u23B5";
	case "&SquareSubset;": return "\u228F";
	case "&ShortUpArrow;": return "\u2191";
	case "&RoundImplies;": return "\u2970";
	case "&RightCeiling;": return "\u2309";
	case "&Proportional;": return "\u221D";
	case "&NotLessTilde;": return "\u2274";
	case "&NotLessEqual;": return "\u2270";
	case "&NotHumpEqual;": return "\u224F\u0338";
	case "&NotCongruent;": return "\u2262";
	case "&LeftUpVector;": return "\u21BF";
	case "&LeftTriangle;": return "\u22B2";
	case "&LeftTeeArrow;": return "\u21A4";
	case "&LeftArrowBar;": return "\u21E4";
	case "&Intersection;": return "\u22C2";
	case "&HumpDownHump;": return "\u224E";
	case "&HilbertSpace;": return "\u210B";
	case "&GreaterTilde;": return "\u2273";
	case "&GreaterEqual;": return "\u2265";
	case "&ExponentialE;": return "\u2147";
	case "&DownTeeArrow;": return "\u21A7";
	case "&DownArrowBar;": return "\u2913";
	case "&varsupsetneqq;": return "\u2ACC\uFE00";
	case "&varsubsetneqq;": return "\u2ACB\uFE00";
	case "&upharpoonleft;": return "\u21BF";
	case "&triangleright;": return "\u25B9";
	case "&smallsetminus;": return "\u2216";
	case "&shortparallel;": return "\u2225";
	case "&ntriangleleft;": return "\u22EA";
	case "&measuredangle;": return "\u2221";
	case "&looparrowleft;": return "\u21AB";
	case "&longleftarrow;": return "\u27F5";
	case "&leftharpoonup;": return "\u21BC";
	case "&leftarrowtail;": return "\u21A2";
	case "&hookleftarrow;": return "\u21A9";
	case "&fallingdotseq;": return "\u2252";
	case "&divideontimes;": return "\u22C7";
	case "&blacktriangle;": return "\u25B4";
	case "&bigtriangleup;": return "\u25B3";
	case "&VeryThinSpace;": return "\u200A";
	case "&VerticalTilde;": return "\u2240";
	case "&UpEquilibrium;": return "\u296E";
	case "&SupersetEqual;": return "\u2287";
	case "&SucceedsTilde;": return "\u227F";
	case "&SucceedsEqual;": return "\u2AB0";
	case "&RightUpVector;": return "\u21BE";
	case "&RightTriangle;": return "\u22B3";
	case "&RightTeeArrow;": return "\u21A6";
	case "&RightArrowBar;": return "\u21E5";
	case "&PrecedesTilde;": return "\u227E";
	case "&PrecedesEqual;": return "\u2AAF";
	case "&Poincareplane;": return "\u210C";
	case "&NotTildeTilde;": return "\u2249";
	case "&NotTildeEqual;": return "\u2244";
	case "&NotEqualTilde;": return "\u2242\u0338";
	case "&Longleftarrow;": return "\u27F8";
	case "&LongLeftArrow;": return "\u27F5";
	case "&LessFullEqual;": return "\u2266";
	case "&LeftVectorBar;": return "\u2952";
	case "&LeftTeeVector;": return "\u295A";
	case "&DoubleUpArrow;": return "\u21D1";
	case "&DoubleLeftTee;": return "\u2AE4";
	case "&DifferentialD;": return "\u2146";
	case "&ApplyFunction;": return "\u2061";
	case "&upharpoonright;": return "\u21BE";
	case "&trianglelefteq;": return "\u22B4";
	case "&rightharpoonup;": return "\u21C0";
	case "&rightarrowtail;": return "\u21A3";
	case "&ntriangleright;": return "\u22EB";
	case "&nshortparallel;": return "\u2226";
	case "&looparrowright;": return "\u21AC";
	case "&longrightarrow;": return "\u27F6";
	case "&leftthreetimes;": return "\u22CB";
	case "&leftrightarrow;": return "\u2194";
	case "&leftleftarrows;": return "\u21C7";
	case "&hookrightarrow;": return "\u21AA";
	case "&downdownarrows;": return "\u21CA";
	case "&doublebarwedge;": return "\u2306";
	case "&curvearrowleft;": return "\u21B6";
	case "&ZeroWidthSpace;": return "\u200B";
	case "&UpperLeftArrow;": return "\u2196";
	case "&TildeFullEqual;": return "\u2245";
	case "&SquareSuperset;": return "\u2290";
	case "&ShortLeftArrow;": return "\u2190";
	case "&ShortDownArrow;": return "\u2193";
	case "&RightVectorBar;": return "\u2953";
	case "&RightTeeVector;": return "\u295B";
	case "&ReverseElement;": return "\u220B";
	case "&OpenCurlyQuote;": return "\u2018";
	case "&NotVerticalBar;": return "\u2224";
	case "&NotSubsetEqual;": return "\u2288";
	case "&NotLessGreater;": return "\u2278";
	case "&NotGreaterLess;": return "\u2279";
	case "&NestedLessLess;": return "\u226A";
	case "&LowerLeftArrow;": return "\u2199";
	case "&Longrightarrow;": return "\u27F9";
	case "&LongRightArrow;": return "\u27F6";
	case "&LessSlantEqual;": return "\u2A7D";
	case "&Leftrightarrow;": return "\u21D4";
	case "&LeftRightArrow;": return "\u2194";
	case "&LeftDownVector;": return "\u21C3";
	case "&InvisibleTimes;": return "\u2062";
	case "&InvisibleComma;": return "\u2063";
	case "&HorizontalLine;": return "\u2500";
	case "&GreaterGreater;": return "\u2AA2";
	case "&DownLeftVector;": return "\u21BD";
	case "&DoubleRightTee;": return "\u22A8";
	case "&DiacriticalDot;": return "\u02D9";
	case "&vartriangleleft;": return "\u22B2";
	case "&trianglerighteq;": return "\u22B5";
	case "&straightepsilon;": return "\u03F5";
	case "&rightthreetimes;": return "\u22CC";
	case "&rightsquigarrow;": return "\u219D";
	case "&rightleftarrows;": return "\u21C4";
	case "&ntrianglelefteq;": return "\u22EC";
	case "&nleftrightarrow;": return "\u21AE";
	case "&nLeftrightarrow;": return "\u21CE";
	case "&leftrightarrows;": return "\u21C6";
	case "&leftharpoondown;": return "\u21BD";
	case "&downharpoonleft;": return "\u21C3";
	case "&curvearrowright;": return "\u21B7";
	case "&circlearrowleft;": return "\u21BA";
	case "&bigtriangledown;": return "\u25BD";
	case "&UpperRightArrow;": return "\u2197";
	case "&ShortRightArrow;": return "\u2192";
	case "&RightDownVector;": return "\u21C2";
	case "&OverParenthesis;": return "\u23DC";
	case "&NotSquareSubset;": return "\u228F\u0338";
	case "&NotLeftTriangle;": return "\u22EA";
	case "&NotHumpDownHump;": return "\u224E\u0338";
	case "&NotGreaterTilde;": return "\u2275";
	case "&NotGreaterEqual;": return "\u2271";
	case "&LowerRightArrow;": return "\u2198";
	case "&LeftUpVectorBar;": return "\u2958";
	case "&LeftUpTeeVector;": return "\u2960";
	case "&LeftTriangleBar;": return "\u29CF";
	case "&LeftRightVector;": return "\u294E";
	case "&DownRightVector;": return "\u21C1";
	case "&DoubleLeftArrow;": return "\u21D0";
	case "&DoubleDownArrow;": return "\u21D3";
	case "&ContourIntegral;": return "\u222E";
	case "&CloseCurlyQuote;": return "\u2019";
	case "&vartriangleright;": return "\u22B3";
	case "&twoheadleftarrow;": return "\u219E";
	case "&rightrightarrows;": return "\u21C9";
	case "&rightharpoondown;": return "\u21C1";
	case "&ntrianglerighteq;": return "\u22ED";
	case "&downharpoonright;": return "\u21C2";
	case "&circlearrowright;": return "\u21BB";
	case "&UpArrowDownArrow;": return "\u21C5";
	case "&UnderParenthesis;": return "\u23DD";
	case "&RightUpVectorBar;": return "\u2954";
	case "&RightUpTeeVector;": return "\u295C";
	case "&RightTriangleBar;": return "\u29D0";
	case "&NotSupersetEqual;": return "\u2289";
	case "&NotSucceedsTilde;": return "\u227F\u0338";
	case "&NotSucceedsEqual;": return "\u2AB0\u0338";
	case "&NotRightTriangle;": return "\u22EB";
	case "&NotPrecedesEqual;": return "\u2AAF\u0338";
	case "&NonBreakingSpace;": return "\u00A0";
	case "&LessEqualGreater;": return "\u22DA";
	case "&LeftUpDownVector;": return "\u2951";
	case "&LeftAngleBracket;": return "\u27E8";
	case "&GreaterFullEqual;": return "\u2267";
	case "&GreaterEqualLess;": return "\u22DB";
	case "&EmptySmallSquare;": return "\u25FB";
	case "&DownArrowUpArrow;": return "\u21F5";
	case "&DoubleRightArrow;": return "\u21D2";
	case "&DiacriticalTilde;": return "\u02DC";
	case "&DiacriticalGrave;": return "\u0060";
	case "&DiacriticalAcute;": return "\u00B4";
	case "&twoheadrightarrow;": return "\u21A0";
	case "&rightleftharpoons;": return "\u21CC";
	case "&leftrightharpoons;": return "\u21CB";
	case "&blacktriangleleft;": return "\u25C2";
	case "&blacktriangledown;": return "\u25BE";
	case "&VerticalSeparator;": return "\u2758";
	case "&SquareSubsetEqual;": return "\u2291";
	case "&RightUpDownVector;": return "\u294F";
	case "&RightAngleBracket;": return "\u27E9";
	case "&NotTildeFullEqual;": return "\u2247";
	case "&NotSquareSuperset;": return "\u2290\u0338";
	case "&NotReverseElement;": return "\u220C";
	case "&NotNestedLessLess;": return "\u2AA1\u0338";
	case "&NotLessSlantEqual;": return "\u2A7D\u0338";
	case "&NotGreaterGreater;": return "\u226B\u0338";
	case "&NegativeThinSpace;": return "\u200B";
	case "&LeftTriangleEqual;": return "\u22B4";
	case "&LeftDownVectorBar;": return "\u2959";
	case "&LeftDownTeeVector;": return "\u2961";
	case "&LeftDoubleBracket;": return "\u27E6";
	case "&GreaterSlantEqual;": return "\u2A7E";
	case "&FilledSmallSquare;": return "\u25FC";
	case "&DownLeftVectorBar;": return "\u2956";
	case "&DownLeftTeeVector;": return "\u295E";
	case "&DoubleVerticalBar;": return "\u2225";
	case "&DoubleUpDownArrow;": return "\u21D5";
	case "&longleftrightarrow;": return "\u27F7";
	case "&blacktriangleright;": return "\u25B8";
	case "&SucceedsSlantEqual;": return "\u227D";
	case "&SquareIntersection;": return "\u2293";
	case "&RightTriangleEqual;": return "\u22B5";
	case "&RightDownVectorBar;": return "\u2955";
	case "&RightDownTeeVector;": return "\u295D";
	case "&RightDoubleBracket;": return "\u27E7";
	case "&ReverseEquilibrium;": return "\u21CB";
	case "&PrecedesSlantEqual;": return "\u227C";
	case "&NotLeftTriangleBar;": return "\u29CF\u0338";
	case "&NegativeThickSpace;": return "\u200B";
	case "&Longleftrightarrow;": return "\u27FA";
	case "&LongLeftRightArrow;": return "\u27F7";
	case "&DownRightVectorBar;": return "\u2957";
	case "&DownRightTeeVector;": return "\u295F";
	case "&leftrightsquigarrow;": return "\u21AD";
	case "&SquareSupersetEqual;": return "\u2292";
	case "&RightArrowLeftArrow;": return "\u21C4";
	case "&NotRightTriangleBar;": return "\u29D0\u0338";
	case "&NotGreaterFullEqual;": return "\u2267\u0338";
	case "&NegativeMediumSpace;": return "\u200B";
	case "&LeftArrowRightArrow;": return "\u21C6";
	case "&DownLeftRightVector;": return "\u2950";
	case "&DoubleLongLeftArrow;": return "\u27F8";
	case "&ReverseUpEquilibrium;": return "\u296F";
	case "&OpenCurlyDoubleQuote;": return "\u201C";
	case "&NotSquareSubsetEqual;": return "\u22E2";
	case "&NotLeftTriangleEqual;": return "\u22EC";
	case "&NotGreaterSlantEqual;": return "\u2A7E\u0338";
	case "&NotDoubleVerticalBar;": return "\u2226";
	case "&NestedGreaterGreater;": return "\u226B";
	case "&EmptyVerySmallSquare;": return "\u25AB";
	case "&DoubleLongRightArrow;": return "\u27F9";
	case "&DoubleLeftRightArrow;": return "\u21D4";
	case "&CapitalDifferentialD;": return "\u2145";
	case "&NotSucceedsSlantEqual;": return "\u22E1";
	case "&NotRightTriangleEqual;": return "\u22ED";
	case "&NotPrecedesSlantEqual;": return "\u22E0";
	case "&NegativeVeryThinSpace;": return "\u200B";
	case "&FilledVerySmallSquare;": return "\u25AA";
	case "&DoubleContourIntegral;": return "\u222F";
	case "&CloseCurlyDoubleQuote;": return "\u201D";
	case "&NotSquareSupersetEqual;": return "\u22E3";
	case "&DiacriticalDoubleAcute;": return "\u02DD";
	case "&NotNestedGreaterGreater;": return "\u2AA2\u0338";
	case "&DoubleLongLeftRightArrow;": return "\u27FA";
	case "&ClockwiseContourIntegral;": return "\u2232";
	case "&CounterClockwiseContourIntegral;": return "\u2233";
	default: return str;
	}
}
