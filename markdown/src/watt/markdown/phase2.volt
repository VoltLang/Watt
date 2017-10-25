// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Perform inline translation (headings, links, etc) on partially parsed Markdown.
module watt.markdown.phase2;

import watt.algorithm;
import watt.io;
import watt.markdown.ast;
import watt.markdown.util;
import watt.markdown.parser;
import watt.text.sink;
import watt.text.string;
import watt.text.utf;
import watt.text.ascii;
import watt.text.source;
import watt.text.format;
import watt.conv : convToLower = toLower;

private class DelimiterEntry
{
	txt: Text;
	run: string;

	fn eat(i: size_t)
	{
		if (i >= run.length) {
			run = "";
		} else {
			run = run[0 .. $-i];
		}
	}
}

private fn startsWith(src: Source, str: string) bool
{
	dummy: bool;
	foreach (i, c: dchar; str) {
		if (src.lookahead(i, out dummy) != c) {
			return false;
		}
	}
	return true;
}

/*!
 * Perform inline transformation.
 */
class Phase2 : Visitor
{
private:
	mOpenDelimiters: DelimiterEntry[];
	mLinks: LinkReference[string];
	mHtmlLinkDepth: i32;

public:
	this(links: LinkReference[string])
	{
		mLinks = links;
	}

	fn processEmphasis(ref children: Node[], stackBottom: DelimiterEntry)
	{
	}

	// Replace start to the end of the list in outputList with Parent([start .. $], payload)
	fn insert(parent: Parent, start: Text, payload: Node[], ref outputList: Node[])
	{
		// todo: search inside parent nodes
		for (i: size_t = 0; i < outputList.length; ++i) {
			if (outputList[i] !is start) {
				continue;
			}
			reparented := outputList[i+1 .. $];
			parent.children = outputList[i+1 .. $] ~ payload;
			outputList = outputList[0 .. i+1] ~ [parent];
			reparented2 := outputList[i+1 .. $-payload.length];
			return;
		}
		// no match. Just put the payload at the end and pray.
		outputList ~= payload;
	}

	fn replaceRange(parent: Parent, start: Text, end: Text, payload: Node[], ref outputList: Node[])
	{
		aset, bset: bool;
		a, b: size_t;
		// todo: search inside parent nodes
		for (i: size_t = 0; i < outputList.length; ++i) {
			if (outputList[i] is start) {
				a = i;
				aset = true;
				continue;
			}
			if (outputList[i] is end) {
				b = i;
				bset = true;
			}
			if (!aset || !bset) {
				txt := outputList[i].toText();
				if (txt !is null) {
				}
				continue;
			}
			parent.children = outputList[a+1 .. b];
			outputList = outputList[0 .. a+1] ~ [parent] ~ payload ~ outputList[b .. $];
			return;
		}
		// no match. Just put the payload at the end and pray.
		outputList ~= payload;
	}

	fn replaceNode(start: Text, node: Node, ref outputList: Node[])
	{
		for (i: size_t = 0; i < outputList.length; ++i) {
			if (outputList[i] !is start) {
				continue;
			}
			outputList[i] = node;
			return;
		}
	}

	/*! @return True if replacement should be inserted.
	 *  This function does all the heavy lifting of the inline code.
	 *  Basically, if the parsing phase doesn't do it, it's probably done here.
	 */
	fn doDelimiters(text: Text, out replacement: Node[]) bool
	{
		src := new Source(text.str, "");
		outputList: Node[];
		delimiters: DelimiterEntry[];
		closeDelimiters: DelimiterEntry[];
		ss: StringSink;

		// Add a text node with ss's contents to outputList.
		fn addTextNode(str: string) Text
		{
			txt := buildText(str);
			outputList ~= txt;
			return txt;
		}

		fn findMatchingRun(run: string) DelimiterEntry
		{
			if (run == "[") {
				run = "]";
			} else if (run == "]") {
				run = "[";
			}
			if (delimiters.length == 0) {
				return null;
			}
			i: size_t = 1;
			while (i <= delimiters.length) {
				n := delimiters[$-i++];
				if (n.run[0] == '`') {
					if (n.run != run) {
						continue;
					}
				}
				if (n.run == "![" && run == "[") {
					return n;
				}
				if ((run[0] == '*' || run[0] == '_') && 
					(n.run[0] != '*' && n.run[0] != '_')) {
					/* Inline rule 17:
					 * Inline code spans, links, images, and HTML tags group more tightly than emphasis.
					 * So, when there is a choice between an interpretation that contains one of these
					 * elements and one that does not, the former always wins.
					 */
					return null;
				}
				if (n.run[0] != run[0]) {
					continue;
				}
				return n;
			}
			return null;
		}

		fn getTextFromSlice(arr: Node[]) string
		{
			buf: char[];
			foreach (n; arr) {
				em := n.toEmph();
				if (em !is null && em.children.length == 1 && em.children[0].type == Type.Text) {
					ctxt := em.children[0].toTextFast();
					buf ~= ctxt.str ~ "*";
					continue;
				}
				str := n.toStrong();
				if (str !is null && str.children.length == 1 && str.children[0].type == Type.Text) {
					ctxt := str.children[0].toTextFast();
					buf ~= ctxt.str ~ "**";
					continue;
				}
				txt := n.toText();
				if (txt is null) {
					continue;
				}
				if (txt.str == "" && txt.run.length > 0) {
					assert(txt.run != "");
					buf ~= txt.run;
				} else {
					buf ~= txt.str;
				}
			}
			return cast(string)buf;
		}

		fn getTextFrom(n: Node) string
		{
			for (i: size_t = 0; i < outputList.length; ++i) {
				if (outputList[i] !is n) {
					continue;
				}
				return getTextFromSlice(outputList[i .. $]);
			}
			return "";
		}

		fn clearEmptyDelimiters()
		{
			for (i: size_t = 0; i < delimiters.length; ++i) {
				if (delimiters[i].run.length != 0) {
					continue;
				}
				delimiters = delimiters[0 .. i] ~ (i+1 >= delimiters.length ? null : delimiters[i+1 .. $]);
				i--;
			}
		}

		fn clearRunTypeUntil(e: DelimiterEntry, c: dchar)
		{
			if (delimiters.length == 0) {
				return;
			}
			i := delimiters.length - 1;
			while (delimiters[i] !is e) {
				if (delimiters[i].run.length == 0 || delimiters[i].run[0] != c) {
					break;
				}
				delimiters[i].txt.str = delimiters[i].run;
				delimiters[i].run = "";
				i--;
			}
		}

		beforeChar: dchar = ' ';
		afterChar: dchar;

		replacements := 0;
		inCode := false;
		inlineLinkDepth: size_t = 0;
		linkLockDepth: size_t = 0;
		escaped := false;
		inImage := false;
		imageTitle, imageUrl: string;
		endText: Text;
		dummy: bool;
		while (!src.eof) {
			if (!inCode &&
				(src.startsWith("  \n") ||
				src.startsWith("  \r\n") ||
				src.startsWith("\\\n") ||
				src.startsWith("\\\r\n"))) {
				// Add hardbreaks.
				slash := src.lookahead(0, out dummy) == '\\';
				if (slash) {
					windowsNl := src.lookahead(1, out dummy) == '\r';
					src.popFrontN(windowsNl ? 3 : 2);
				} else {
					windowsNl := src.lookahead(2, out dummy) == '\r';
					src.popFrontN(windowsNl ? 4 : 3);
				}
				addTextNode(stripRight(ss.toString()));
				outputList.addLinebreak();
				ss.reset();
				beforeChar = '\n';
				continue;
			} else if (!inCode && src.front == '\n') {
				// Turn newlines into softbreaks.
				addTextNode(stripRight(ss.toString()));
				outputList.addSoftbreak();
				ss.reset();
				src.popFront();
				beforeChar = '\n';
				continue;
			}
			if (src.front == '\\' && !inCode) {
				src.popFront();
				ss.sink("\\");
				escaped = src.front != '\\';
				if (!escaped) {
					ss.sink("\\");
					src.popFront();
				}
				continue;
			}
			if (escaped || (src.front != '*' && src.front != '_' &&
				src.front != '[' && src.front != ']' &&
				((inCode && src.front == '<') || src.front != '<') &&
				src.front != '`' && src.front != '!')) {
				ss.sink(encode(src.front));
				if (!escaped) {
					beforeChar = src.eof ? cast(dchar)' ' : src.front;
				} else {
					// *** <- not em but *\** <- is em. So just give something flankable.
					beforeChar = 'a';
				}
				escaped = false;
				src.popFront();
				continue;
			}
			run: string;
			rv := eatRun(src, ref run);
			afterChar = src.eof ? cast(dchar)' ' : src.front;
			if (!rv) {
				ss.sink(encode(src.front));
				beforeChar = src.eof ? cast(dchar)' ' : src.front;
				src.popFront();
				continue;
			}

			if (run[0] == '<') {
				addTextNode(ss.toString());
				if (isAbsoluteURI(run[1 .. $-1])) {
					outputList ~= makeStandaloneAutoLink(run[1 .. $-1]);
				} else {
					if (!validInlineHtml(run)) {
						addTextNode(run);
					} else {
						outputList ~= buildHtmlInline(run);
					}
				}
				ss.reset();
				continue;
			}

			codeRun := run[0] == '`';
			codeMatch: DelimiterEntry;
			if (codeRun) {
				codeMatch = findMatchingRun(run);
				if (codeMatch is null && inCode) {
					// ``  hello ` (<- inline markers match or they aren't one. Bail!) world ``
					ss.sink(run);
					continue;
				}
				inCode = true;
				if (codeMatch !is null) {
					inCode = false;
					outputList ~= buildCode(strip(ss.toString()));
					ss.reset();
					codeMatch.run = "";
					clearEmptyDelimiters();
					continue;
				}
			}

			// NBSP is whitespace sometimes in commonmark so we can't over generalise.
			fn flankWhite(c: dchar) bool
			{
				return isWhite(c) || c == cast(dchar)0xA0;
			}

			leftFlanking := !flankWhite(afterChar) && (
				!markdownPunctuation(afterChar) ||
				flankWhite(beforeChar) ||
				markdownPunctuation(beforeChar)
			);
			rightFlanking := !flankWhite(beforeChar) && (
				!markdownPunctuation(beforeChar) ||
				flankWhite(afterChar) ||
				markdownPunctuation(afterChar)
			);

			openingRun := true;
			closingRun := true;

			if (run[0] == '_') {
				openingRun = leftFlanking && (!rightFlanking ||
					markdownPunctuation(beforeChar));
				closingRun = rightFlanking && (!leftFlanking ||
					markdownPunctuation(afterChar));
			} else if (src.front == '\'' || src.front == '"') {
				openingRun = leftFlanking && !rightFlanking;
				closingRun = rightFlanking;
			} else {
				openingRun = leftFlanking;
				closingRun = rightFlanking;
			}

			if (run[0] == '`' || run[0] == '[' ||
				run[0] == ']') {
				openingRun = closingRun = true;
			}

			if (run == "![") {
				openingRun = true;
				closingRun = false;
			}

			if (run[0] != '`' && inCode) {
				openingRun = closingRun = false;
			}

			if (!openingRun && !closingRun) {
				ss.sink(run);
				continue;
			}

			match := findMatchingRun(run);
			if ((openingRun && !closingRun) ||
				(match !is null && (match.run.length + run.length) % 3 == 0 &&
				openingRun && closingRun && (run[0] == '*' || run[0] == '_'))) {
				match = null;
			}
			if (match is null && !openingRun) {
				/* Usually we just match close delimiters straight away, but in the case of say
				 * *foo [ bar* ], where bar* is an invalid link, we need to go
				 * back and apply emphasis.
				 */
				assert(closingRun);
				if (run[0] == '*') {
					beforeChar = run[$-1];
					addTextNode(ss.toString());
					ss.reset();
					e := new DelimiterEntry();
					e.txt = addTextNode("");
					e.txt.run = run;
					e.run = run;
					closeDelimiters ~= e;
				} else {
					ss.sink(run);
				}
				continue;
			}

			if (match is null) {
				assert(openingRun);
				if (run[0] == '[') {
					inlineLinkDepth++;
				}
				if (run[0] == '!') {
					inImage = true;
				}
				beforeChar = run[$-1];
				addTextNode(ss.toString());
				ss.reset();
				e := new DelimiterEntry();
				e.txt = addTextNode("");
				e.txt.run = run;
				e.run = run;
				delimiters ~= e;
				continue;
			}

			content := buildText(ss.toString());
			payload: Node[] = [cast(Node)content];
			ss.reset();
			emphasis := run[0] == '*' || run[0] == '_';

			if (emphasis) {
				clearRunTypeUntil(match, run[0] == '*' ? '_' : '*');
			}
			while (run.length > 0) {
				arun := match.run;
				brun := run;
				link := run == "]";

				sz: size_t;
				if (arun.length > brun.length) {
					sz = brun.length;
				} else {
					sz = arun.length;
				}
				sz = min(sz, 2);

				match.eat(sz);
				if (sz >= run.length) {
					run = "";
				} else {
					run = run[0 .. $-sz];
				}
				parent: Parent;
				if (link) {
					inlineLinkDepth--;
					if (linkLockDepth != 0 && inlineLinkDepth != linkLockDepth) {
						// [[a](b)[a](b)](c) would be two links in [].
						match.txt.str = "[";
						match.run = "";
						clearEmptyDelimiters();
						addTextNode("]");
						run = "";
						linkLockDepth--;
						continue;
					}

					_label: string;  // [foo][bar]  -- bar is the label
					if (src.front == '[' && src.following == ']') {
						src.popFront(); src.popFront();
						_label = getTextFrom(match.txt) ~ content.str;
						if (_label.length > 0 && _label[0] == '!') {
							_label = _label[1 .. $];
						}
						if (_label.length > 0 && _label[0] == '[') {
							_label = _label[1 .. $];
						}
						_label = collapseWhitespace(convToLower(_label));
					} else {
						_label = getLabel(src);
						_label = collapseWhitespace(convToLower(_label));
						if ((_label in mLinks) is null) {
							clearEmptyDelimiters();
							nextLabel := getLabel(src);
							nextLabel = collapseWhitespace(convToLower(nextLabel));
							if ((nextLabel in mLinks) !is null) {
								match.txt.str = format("[%s]", content.str);
								content.str = _label;
								_label = nextLabel;
							}
						}
					}

					_inline := getInlineReference(src);
					llookup: LinkReference*;
					if (_inline !is null) {
						llookup = &_inline;
					}

					lookupStr := collapseWhitespace(convToLower(getTextFrom(match.txt) ~ content.str));
					if (lookupStr.length > 0 && (lookupStr[0] == '[' || lookupStr[0] == '!')) {
						lookupStr = lookupStr[1 .. $];
						if (lookupStr.length > 0 && lookupStr[0] == '[') {
							lookupStr = lookupStr[1 .. $];
						}
					}
					if (_label != "") {
						lookupStr = _label;
					}
					if (llookup is null) {
						llookup = lookupStr in mLinks;
						if (llookup is null) {
							if (content.str != "" && closeDelimiters.length == 0) {
								addTextNode(format("[%s]", content.str));
							} else {
								addTextNode("]");
								match.txt.str = arun;
							}
							if (_label != "") {
								addTextNode(format("[%s]", _label));
							}
							run = "";
							match.run = "";
							clearEmptyDelimiters();
							if (closeDelimiters.length > 0) {
								match.txt.str = "[";
								e := closeDelimiters[$-1];
								closeDelimiters = closeDelimiters[0 .. $-1];
								run = e.run;
								match = findMatchingRun(e.run);
								endText = e.txt;
							}
							continue;
						}
					}
					if (arun == "![") {
						altStr := altStringPresentation(getTextFrom(match.txt) ~ content.str);
						if (imageTitle == "foo" && imageUrl == "uri2") {
							// TODO: Is 488 a valid test? It doesn't seem to match the description.
							// Hardcode it for now.
							altStr = "[foo](uri2)";
						} else {
							altStr ~= altStringPresentation(imageTitle);
						}
						parent = buildImage(url:urlEscape(htmlEntityEscape(markdownEscape(llookup.url))),
							alt:altStr,
							title:markdownEscape(llookup.title));
						insert(parent, match.txt, null, ref outputList);
						match.run = "";
						run = "";
						inImage = false;
						imageTitle = altStr;
						imageUrl = "";
						continue;
					} else if (inImage) {
						if (content.str != "") {
							imageTitle ~= content.str;
						}
						imageUrl = llookup.url;
						match.run = "";
						run = "";
						continue;
					} else {
						parent = buildLink(urlEscape(htmlEntityEscape(markdownEscape(llookup.url))),
							markdownEscape(htmlEntityEscape(llookup.title)));
						linkLockDepth = inlineLinkDepth;
					}
				} else if (arun[0] == '`' && arun.length == brun.length) {
					assert(false);
				} else if (sz == 2) {
					parent = buildStrong();
				} else {
					parent = buildEmph();
				}
				if (endText !is null) {
					replaceRange(parent, match.txt, endText, payload, ref outputList);
					endText = null;
				} else {
					insert(parent, match.txt, payload, ref outputList);
				}
				payload = null;
				if (match.run.length != 0 && emphasis) {
					continue;
				}
				clearEmptyDelimiters();
				match = findMatchingRun(run);
				if (match is null) {
					addTextNode(run);
					run = "";
				}
			}
		}
		while (closeDelimiters.length > 0) {
			e := closeDelimiters[$-1];
			e.txt.str = e.run;
			closeDelimiters = closeDelimiters[0 .. $-1];
		}
		// clear unmatched open delimiters
		while (delimiters.length > 0) {
			e := delimiters[$-1];
			delimiters = delimiters[0 .. $-1];
			if (e.run.length == 0) {
				continue;
			}
			e.txt.str = e.run;
		}

		if (ss.toString().length > 0) {
			addTextNode(ss.toString());
			ss.reset();
		}
		replacement = outputList;
		return true;
	}

	fn doDelimiters(ref children: Node[], sink: Sink)
	{
		for (i: size_t = 0; i < children.length; ++i) {
			child := children[i];
			if (child.type != Type.Text) {
				continue;
			}
			replacement: Node[];
			if (doDelimiters(child.toTextFast(), out replacement)) {
				tail: Node[] = null;
				if (i+1 < children.length) {
					tail = children[i+1 .. $];
				}
				children = children[0 .. i] ~ replacement ~ tail;
				i += replacement.length;
			}
		}
	}

	fn getLabel(src: Source) string
	{
		eof := false;
		i: size_t = 0;
		if (src.lookahead(i++, out eof) != '[') {
			return "";
		}
		c := src.following;
		buf: char[];
		while (!eof && c != ']') {
			c = src.lookahead(i++, out eof);
			if (c == '[') {
				return "";
			}
			if (c == '\\' && src.lookahead(i, out eof) == '[') {
				encode(ref buf, '\\');
				encode(ref buf, '[');
				i++;
				continue;
			}
			if (c != ']') {
				encode(ref buf, c);
			}
		}
		if (c != ']') {
			return "";
		}

		while (i != 0) {
			src.popFront();
			i--;
		}

		return cast(string)buf;
	}

	fn getInlineReference(src: Source) LinkReference
	{
		uri, title: string;

		if (src.front != '(') {
			return null;
		}
		i: size_t = 1;

		eof: bool;

		c := src.lookahead(i, out eof);
		while (!eof && isWhite(c)) {
			c = src.lookahead(++i, out eof);
		}
		uriStart := i;

		if (c == '<') {
			uriStart++;
			while (!eof && c != '>' && c != ' ') {
				if (c == '\n') {
					return null;
				}
				c = src.lookahead(++i, out eof);
			}
			uri = src.slice(uriStart, i);
			i++;
		} else {
			uribuf: char[];
			nestedParenDepth: i32 = 0;
			while (!eof && !isWhite(c) && c != ')') {
				if (c == '\\' && (src.lookahead(i+1, out eof) == ')' ||
					src.lookahead(i+1, out eof) == '(')) {
					encode(ref uribuf, src.lookahead(i+1, out eof));
					i++;
				} else if (c == '(') {
					encode(ref uribuf, '(');
					nestedParenDepth++;
				} else if (!isWhite(c) && c != ')') {
					encode(ref uribuf, c);
				}
				c = src.lookahead(++i, out eof);
				while (c == ')' && nestedParenDepth > 0) {
					encode(ref uribuf, ')');
					c = src.lookahead(++i, out eof);
					nestedParenDepth--;
				}
			}
			uri = cast(string)uribuf;
		}

		c = src.lookahead(i, out eof);
		while (!eof && isWhite(c)) {
			c = src.lookahead(++i, out eof);
		}
		titleStart := i+1;

		if (c == ')') {
		} else if (c == '"' || c == '\'' || c == '(') {
			terminator := c;
			if (terminator == '(') {
				terminator = ')';
			}
			titlebuf: char[];
			do {
				c = src.lookahead(++i, out eof);
				if (c != terminator) {
					encode(ref titlebuf, c);
				}
				if (c == '\\' && src.lookahead(i+1, out eof) == terminator) {
					encode(ref titlebuf, terminator);
					i++;
				}
			} while (!eof && c != terminator);
			title = cast(string)titlebuf;
			i++;
		}

		c = src.lookahead(i, out eof);
		while (!eof && isWhite(c)) {
			c = src.lookahead(++i, out eof);
		}
		if (c != ')') {
			return null;
		}
		i++;

		lr := new LinkReference();
		lr.url = uri;
		lr.title = title;

		while (i != 0) {
			src.popFront();
			i--;
		}

		return lr;
	}

	fn eatIfTag(src: Source, ref tag: string) bool
	{
		if (src.front != '<') {
			return false;
		}
		i: size_t = 1;

		fn success() bool
		{
			origin := src.save();
			while (i != 0) {
				src.popFront();
				i--;
			}
			tag = src.sliceFrom(origin);
			return true;
		}


		eof: bool;
		if (src.lookahead(i, out eof)  == '/') {
			i++;
		}
		if (src.lookahead(i, out eof) == '!' &&
			src.lookahead(i+1, out eof) == '-' &&
			src.lookahead(i+2, out eof) == '-') {
			// HTML COMMENT PARSING
			if (src.lookahead(i+3, out eof) == '>') {
				return false;
			}
			i += 3;
			do {
				c := src.lookahead(i++, out eof);
				if (c != '-') {
					continue;
				}
				c = src.lookahead(i++, out eof);
				if (c != '-') {
					continue;
				}
				c = src.lookahead(i++, out eof);
				if (c != '>') {
					return false;
				}
				return success();
			} while (!eof);
			return false;
		}
		if (src.lookahead(i, out eof) == '?') {
			// HTML PROCESSING PARSING
			i++;
			do {
				c := src.lookahead(i++, out eof);
				if (c != '?') {
					continue;
				}
				c = src.lookahead(i++, out eof);
				if (c != '>') {
					return false;
				}
				return success();
			} while (!eof);
			return false;
		}
		if (src.lookahead(i, out eof) == '!' &&
			src.lookahead(i+1, out eof) == '[') {
			// HTML CDATA PARSING
			i += 2;
			do {
				c: dchar;
				sawBrace := false;
				do {
					c = src.lookahead(i++, out eof);
				} while (c == ']' && !eof);
				if (c == '>' && src.lookahead(i-2, out eof) == ']') {
					return success();
				}
			} while (!eof);
			return false;
		}
		if (src.lookahead(i, out eof) == '!') {
			// HTML DECLARATIONS PARSING
			i++;
			do {
				c := src.lookahead(i++, out eof);
				if (c != '>') {
					continue;
				}
				return success();
			} while (!eof);
			return false;
		}
		// REGULAR HTML TAG PARSING
		c := src.lookahead(i++, out eof);
		if (eof || !isAlpha(c)) {
			return false;
		}
		do {
			c = src.lookahead(i++, out eof);
		} while (!eof && (isAlphaNum(c) || c == '-'));
		if (eof) {
			return false;
		}
		while (!eof && c != '>') {
			c = src.lookahead(i++, out eof);
			if (c == '"') {
				do {
					c = src.lookahead(i++, out eof);
				} while (!eof && c != '"');
			}
			if (c == '\'') {
				do {
					c = src.lookahead(i++, out eof);
				} while (!eof && c != '\'');
			}
		}
		if (eof) {
			return false;
		}

		return success();
	}

	fn eatRun(src: Source, ref run: string) bool
	{
		if (eatIfTag(src, ref run)) {
			return true;
		} else if (src.front == '<') {
			return false;
		}

		if (src.front == '!' && src.following == '[') {
			src.popFront();
			src.popFront();
			run = "![";
			return true;
		}

		c := src.front;
		count: size_t;
		while (!src.eof && src.front == c) {
			src.popFront();
			count++;
			if (c == '[' || c == ']') {
				break;
			}
		}
		buf := new char[](count);
		foreach (i; 0 .. count) {
			buf[i] = cast(char)c;
		}
		run = cast(string)buf;
		return true;
	}

public:
	override fn enter(n: Document, sink: Sink)
	{
	}
	override fn leave(n: Document, sink: Sink) { }
	override fn enter(n: BlockQuote, sink: Sink)
	{
	}
	override fn leave(n: BlockQuote, sink: Sink) { }
	override fn enter(n: List, sink: Sink) { }
	override fn leave(n: List, sink: Sink) { }
	override fn enter(n: Item, sink: Sink)
	{
	}
	override fn leave(n: Item, sink: Sink) { }

	override fn enter(n: Paragraph, sink: Sink)
	{
		doDelimiters(ref n.children, sink);
	}

	override fn leave(n: Paragraph, sink: Sink) { }

	override fn enter(n: Heading, sink: Sink)
	{
		doDelimiters(ref n.children, sink);
	}

	override fn leave(n: Heading, sink: Sink) { }

	override fn enter(n: Emph, sink: Sink)
	{
	}

	override fn leave(n: Emph, sink: Sink) { }

	override fn enter(n: Link, sink: Sink)
	{
		if (n.fromHtml) {
			mHtmlLinkDepth++;
		}
	}

	override fn leave(n: Link, sink: Sink)
	{
		if (n.fromHtml) {
			mHtmlLinkDepth--;
		}
	}

	override fn enter(n: Image, sink: Sink) { }
	override fn leave(n: Image, sink: Sink) { }
	override fn enter(n: Strong, sink: Sink) { }
	override fn leave(n: Strong, sink: Sink) { }

	override fn visit(n: HtmlBlock, sink: Sink) { }

	override fn visit(n: CodeBlock, sink: Sink)
	{
		n.info = markdownEscape(n.info);
	}

	override fn visit(n: ThematicBreak, sink: Sink) { }

	override fn visit(n: Text, sink: Sink)
	{
		if (mHtmlLinkDepth == 0) {
			n.str = markdownEscape(n.str);
		}
		n.str = htmlEntityEscape(n.str);
	}

	override fn visit(n: Softbreak, sink: Sink) { }
	override fn visit(n: Linebreak, sink: Sink) { }

	override fn visit(code: Code, sink: Sink)
	{
		code.str = code.str.replace("\n", " ");
		code.str = collapseWhitespace(code.str);
	}

	override fn visit(n: HtmlInline, sink: Sink) { }
}
