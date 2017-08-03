// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Markdown parser.
module watt.markdown.parser;

import watt.algorithm : min;
import watt.conv;
import watt.io;
import watt.markdown.ast;
import watt.markdown.util;
import watt.markdown.phase2;
import watt.markdown.lines;
import watt.text.utf;
import watt.text.string;
import watt.text.ascii;
import watt.text.sink;
import watt.text.html;
import watt.text.format;


fn parse(str: string) Document
{
	p: Parser;
	setup(ref p);
	phase1(ref p, str);
	p.addLinkReference();
	p.addHtml();
	p.popAll();
	assert(p.mDocument !is null);
	p2 := new Phase2(p.mLinkReferences);
	accept(p.mDocument, p2, null);
	return p.mDocument;
}

class LinkReference
{
	enum Stage
	{
		Opening, // [
		Label, // label
		ClosingColon, // ]:
		Url,  // example.com
		Title,  // "title" (optional)
		Done,
	}

	label: string;
	url: string;

	title: string;
	titleSentinel: dchar;  // ' or "

	stage: Stage;

	lines: string[];  // If it turns out this wasn't a reference, we need to add these lines.

	/// Add the lines that made this potential link reference as text to the document.
	fn addLines(ref p: Parser)
	{
		foreach (i, line; p.mLinkReference.lines) {
			l: Line;
			l.set(line, 0);
			parseParagraph(ref p, ref l);
		}
	}
}

private:

fn containsUnescapedBracket(str: string) bool
{
	for (i: size_t = 0; i < str.length; ++i) {
		if (i+1 < str.length && str[i] == '\\' &&
			(str[i+1] == '[' || str[i+1] == ']')) {
			i += 2;
			continue;
		}
		if (str[i] == '[' || str[i] == ']') {
			return true;
		}
	}
	return false;
}

struct Parser
{
private:
	mStack: Entry[];
	mStackNum: size_t;
	mDocument: Document;

	mDelimiter: size_t;
	mDelimiterName: string;
	mImpliedList: bool;
	mChildList: bool;
	mListNumber: i32;  // less than 0 unordered

	mCodeFence: string;  // if non-empty, in a codefence. Contains the value that terminates the fence.
	mExplicitlyClosedCodeFence: bool;

	mLinkReference: LinkReference;  // if non-null, in a link reference.
	mLinkReferences: LinkReference[string];

	mHtml: HtmlBlock;  // If non null, in an html block.

	mLastLineBlank: bool;
	mForceBlank: bool;  // Don't touch mLastLineBlank for the next line.

public:
	fn invalidateLinkReference()
	{
		if (mLinkReference is null) {
			return;
		}
		mLinkReference.addLines(ref this);
		mLinkReference = null;
	}

	fn addHtml()
	{
		if (mHtml is null) {
			return;
		}
		sstr := strip(mHtml.str);
		innerUrl := "";
		if (sstr.length > 2 && sstr[0] == '<' && sstr[$-1] == '>') {
			innerUrl = sstr[1 .. $-1];
		}
		if (isAbsoluteURI(innerUrl)) {
			mHtml.parent.children ~= makeAutoLink(sstr[1 .. $-1]);
		} else if (isEmailAddress(innerUrl)) {
			mHtml.parent.children ~= makeEmailLink(innerUrl);
		} else {
			if (!validBlockHtml(sstr)) {
				line: Line;	
				line.set(mHtml.str, 0);
				parseParagraph(ref this, ref line);
			} else {
				if (mHtml.str.length > 0 && mHtml.str[$-1] == '\n' && mHtml.parent.type == Type.Item) {
					mHtml.str = mHtml.str[0 .. $-1];
				}
				mHtml.parent.children ~= mHtml;
			}
		}
		if (nonParagraphParent() is mHtml.parent && mHtml.parent !is mDocument) {
			pop();
		}
		mHtml = null;
	}

	fn addLinkReference()
	{
		if (mLinkReference is null) {
			return;
		}
		if (mLinkReference.stage != LinkReference.Stage.Done &&
			(mLinkReference.stage != LinkReference.Stage.Title || mLinkReference.title.length > 0)) {
			invalidateLinkReference();
		} else {
			key := collapseWhitespace(mLinkReference.label.toLower());
			if (key.containsUnescapedBracket() || strip(key) == "") {
				invalidateLinkReference();
				return;
			}
			lr := key in mLinkReferences;
			if (lr is null) {
				mLinkReferences[key] = mLinkReference;
			}
		}
		mLinkReference = null;
	}

	fn push(n: Node)
	{
		if (mStackNum >= mStack.length) {
			newStack := new Entry[](mStack.length + 16);
			newStack[0 .. mStack.length] = mStack[..];
			mStack = newStack;
		}

		e: Entry;
		e.n = n;
		mStack[mStackNum++] = e;
	}

	fn popAll()
	{
		while (mStackNum > 0) {
			pop();
		}
	}

	fn pop()
	{
		if (mStackNum <= 0) {
			return;
		}
		if (mStack[mStackNum-1].n.type == Type.Paragraph) {
			closeParagraph();
		}
		if (mStack[mStackNum-1].n.type == Type.CodeBlock) {
			closeCodeBlock();
		}
		mStackNum--;
	}

	// Pop until you pop @p type. Does no error checking.
	fn pop(type: Type)
	{
		while (mStack[mStackNum-1].n.type != type) {
			pop();
		}
		pop();
	}

	fn closeCodeBlock()
	{
		cf := mCodeFence != "" && mExplicitlyClosedCodeFence;
		mCodeFence = "";
		cb := mStack[mStackNum-1].n.toCodeBlockFast();
		if (cf && cb.str.length > 0 && cb.str[$-1] == '\n') {
			cb.str = cb.str[0 .. $-1];
		} else {
			while (cb.str.length > 0 && cb.str[$-1] == '\n') {
				cb.str = cb.str[0 .. $-1];
			}
		}
		if (cb.str.length > 0) {
			cb.str ~= "\n";
		}
		mExplicitlyClosedCodeFence = false;
	}

	fn closeParagraph()
	{
		// Remove final softbreak when closing paragraphs.
		par := mStack[mStackNum-1].n.toParagraphFast();
		assert(par.children.length == 1);
		txt := par.children[0].toTextFast();
		txt.str = stripRight(txt.str);
		assert(txt.str.length > 0);
	}

	fn peek() Node
	{
		return mStackNum > 0 ? mStack[mStackNum-1].n : null;
	}

	fn parent() Parent
	{
		i: size_t;
		while (i != mStackNum) {
			n := mStack[mStackNum - ++i].n;
			asParent := n.toParent();
			if (asParent !is null) {
				return asParent;
			}
		}
		return mDocument.toParentFast();
	}

	fn nonParagraphParent() Parent
	{
		i: size_t;
		while (i != mStackNum) {
			n := mStack[mStackNum - ++i].n;
			if (n.type == Type.Paragraph) {
				continue;
			}
			asParent := n.toParent();
			if (asParent !is null) {
				return asParent;
			}
		}
		return mDocument.toParentFast();
	}

	//! @return The newest node (top of stack->bottom) of @p type, or null.
	fn find(type: Type) Node
	{
		i: size_t;
		while (i != mStackNum) {
			if (mStack[mStackNum - ++i].n.type == type) {
				return mStack[mStackNum - i].n;
			}
		}
		return null;
	}

	fn list() List
	{
		n := find(Type.List);
		return n is null ? null : n.toListFast();
	}

	fn item() Item
	{
		n := find(Type.Item);
		return n is null ? null : n.toItemFast();
	}

	fn htmlblock() HtmlBlock
	{
		n := find(Type.HtmlBlock);
		return n is null ? null : n.toHtmlBlockFast();
	}

	fn codeblock() CodeBlock
	{
		n := find(Type.CodeBlock);
		return n is null ? null : n.toCodeBlockFast();
	}

	fn blockquote() BlockQuote
	{
		n := find(Type.BlockQuote);
		return n is null ? null : n.toBlockQuoteFast();
	}

	fn count(t: Type) size_t
	{
		n: size_t;
		i: size_t;
		while (i != mStackNum) {
			if (mStack[mStackNum - ++i].n.type == t) {
				n++;
			}
		}
		return n;
	}

	fn paragraph() Paragraph
	{
		n := find(Type.Paragraph);
		return n is null ? null : n.toParagraphFast();
	}
}

struct Entry
{
	n: Node;
}

fn setup(ref p: Parser)
{
	p.mDocument = buildDocument();
}

fn phase1(ref p: Parser, str: string)
{
	lines := Line.split(str);
	lastEmpty := false;
	for (i: size_t = 0; i < lines.length; ++i) {
		lastEmpty = lines[i].empty && i != lines.length - 1;
		if (lastEmpty) {
			parseEmpty(ref p, ref lines[i]);
		}
		parseLine(ref p, ref lines[i]);
		if (!p.mForceBlank) {
			p.mLastLineBlank = lastEmpty;
		}
		p.mForceBlank = false;
	}
}

fn parseLine(ref p: Parser, ref line: Line)
{
	while (!line.empty) {
		parseBlock(ref p, ref line);
		line.iterationCount++;
	}
}

fn parseEmpty(ref p: Parser, ref line: Line, skipBQ: bool = false)
{
	list := p.list();
	if (list !is null && p.mCodeFence.length == 0) {
		list.blankLinePending = true;
		if (list.empty && list.children.length <= 1) {
			p.pop(Type.List);
		}
	}

	if (p.peek() !is null && p.peek().type == Type.Paragraph) {
		p.pop();
	}

	cb := p.codeblock();
	if (cb !is null) {
		cb.str ~= "\n";
	}

	bq := p.blockquote();
	if (bq !is null && !skipBQ) {
		p.pop(Type.BlockQuote);
	}

	if (p.mHtml !is null) {
		parseHtmlBlock(ref p, ref line);
	}

	parseLinkReference(ref p, ref line);
}

fn parseBlock(ref p: Parser, ref line: Line)
{
	parseSetextHeading(ref p, ref line);
	parseThematicBreak(ref p, ref line);
	parseBlockQuote(ref p, ref line);
	if (parseList(ref p, ref line)) {
		return;
	}
	parseCodeFence(ref p, ref line);
	parseLinkReference(ref p, ref line);
	parseHtmlBlock(ref p, ref line);
	parseCodeBlock(ref p, ref line);
	parseAtxHeading(ref p, ref line);
	parseParagraph(ref p, ref line);
}

fn parseHtmlBlock(ref p: Parser, ref line: Line)
{
	str := line.toString();
	sstr := strip(str);
	firstLine := false;
	if (p.mHtml is null) {
		leadingWhitespace := countLeadingWhitespace(str);
		if (leadingWhitespace >= 4) {
			return;
		}
		if (sstr.length == 0 || sstr[0] != '<') {
			return;
		}
		sstr = sstr[1 .. $];
		if (sstr.length == 0) {
			return;
		}
		k: HtmlBlock.Kind;
		switch (sstr[0]) {
		case '!':
			sstr = sstr[1 .. $];
			if (sstr.length == 0) {
				return;
			}
			if (isUpper(sstr[0])) {
				k = HtmlBlock.Kind.Bang;
				break;
			}
			if (sstr.length >= 2 && sstr[0 .. 2] == "--") {
				k = HtmlBlock.Kind.Comment;
				break;
			}
			if (sstr.length >= 7 && sstr[0 .. 7] == "[CDATA[") {
				k = HtmlBlock.Kind.CData;
				break;
			}
			return;
		case '?':
			sstr = sstr[1 .. $];
			k = HtmlBlock.Kind.Question;
			break;
		default:
			if (sstr[0] == '/') {
				sstr = sstr[1 .. $];
			}
			tag: string;
			if (!consumeTag(ref sstr, out tag)) {
				return;
			}
			switch (tag) {
			case "script", "pre", "style":
				if (sstr.length != 0 && !(isWhite(sstr[0]) || sstr[0] == '>')) {
					return;
				}
				k = HtmlBlock.Kind.Script;
				break;
			case "address", "article", "aside", "base", "basefont", "blockquote", "body",
				 "caption", "center", "col", "colgroup", "dd", "details", "dir", "div", "dl",
				 "dt", "fieldset", "figcaption", "figure", "footer", "form", "frame", "frameset",
				 "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hr", "html", "iframe",
				 "legend", "li", "link", "main", "menu", "menuitem", "meta", "nav", "noframes", "ol",
				 "optgroup", "option", "p", "param", "section", "source", "summary", "table", "tbody",
				 "td", "tfoot", "th", "thead", "title", "tr", "track", "ul":
				if (sstr.length != 0 && !(isWhite(sstr[0]) || sstr[0] == '>' || (sstr.length >= 2 && sstr[0 .. 2] == "/>"))) {
					return;
				}
				k = HtmlBlock.Kind.Normal;
				break;
			default:
				consumeWhitespace(ref sstr);
				dummy: string;
				if (!consumeUntilChar(ref sstr, out dummy, '>') || sstr.length != 1) {
					return;
				}
				k = HtmlBlock.Kind.Other;
				break;
			}
			break;
		}
		if (k == HtmlBlock.Kind.Other) {
			par := p.paragraph();
			if (par !is null) {
				return;
			}
		}
		p.mHtml = buildHtmlBlock();
		p.mHtml.kind = k;

		p.mHtml.parent = p.nonParagraphParent();
		firstLine = true;
	}

	bq := p.blockquote();
	if (bq !is null) {
		dummyline := line;
		parseBlockQuote(ref p, ref dummyline);
		str = dummyline.toString();
	}

	list := p.list();
	if (list !is null) {
		dummyline := line;
		dummyline.stripRight();
		parseList(ref p, ref dummyline);
		if (firstLine) {
			p.parent().children.addSoftbreak();
		}
		parseParagraph(ref p, ref dummyline);
		str = dummyline.toString();
	}

	line.clear();

	switch (p.mHtml.kind) {
	case HtmlBlock.Kind.Script:
		low := toLower(sstr);
		a := low.indexOf("</script>");
		b := low.indexOf("</pre>");
		c := low.indexOf("</style>");
		if (a >= 0 || b >= 0 || c >= 0) {
			p.mHtml.str ~= str;
			p.addHtml();
			return;
		}
		break;
	case HtmlBlock.Kind.Comment:
		if (sstr.indexOf("-->") >= 0) {
			p.mHtml.str ~= str;
			p.addHtml();
			return;
		}
		break;
	case HtmlBlock.Kind.Question:
		if (sstr.indexOf("?>") >= 0) {
			p.mHtml.str ~= str;
			p.addHtml();
			return;
		}
		break;
	case HtmlBlock.Kind.CData:
		if (sstr.indexOf("]]>") >= 0) {
			p.mHtml.str ~= str;
			p.addHtml();
			return;
		}
		break;
	default:
		if (sstr.length == 0) {
			p.addHtml();
			return;
		}
		break;
	}

	p.mHtml.str ~= str ~ "\n";
}

fn parseSetextHeading(ref p: Parser, ref line: Line)
{
	// First, check that the preceding text is okay.
	peek := p.peek();
	bq := p.blockquote();
	if (peek is null || peek.type != Type.Paragraph || bq !is null) {
		return;
	}
	item := p.item();
	if (item !is null && line.leadingWhitespace < item.childPoint) {
		return;
	}
	par := peek.toParagraphFast();
	str := paragraphToString(par);
	i: size_t;
	rv := countContiguousWhitespace(str, size_t.max, ref i);
	if (rv >= CODE_INDENT || rv == str.length) {
		return;
	}

	// Prior lines look okay, now check the setext line.
	tmpLine := line;
	i = 0;
	rv = tmpLine.leadingWhitespace;
	if (rv >= CODE_INDENT) {
		return;
	}

	lstr := strip(tmpLine.toString());
	if (lstr.length == 0) {
		return;
	}

	if (lstr == "-") {
		// Interpret this as an empty list item.
		return;
	}

	c := lstr[0];
	if (c != '-' && c != '=') {
		return;
	}
	foreach (cc: char; lstr) {
		if (cc != c) {
			return;
		}
	}
	parent := p.nonParagraphParent();
	foreach (j, child; parent.children) {
		if (child is par) {
			level := c == '-' ? 2u : 1u;
			heading := buildHeading(level);
			heading.children = par.children;
			processHeadingContents(ref heading.children);
			parent.children[j] = heading;
			p.pop();
			line.clear();
			return;
		}
	}
}

fn processHeadingContents(ref children: Node[])
{
	if (children.length == 0) {
		return;
	}
	if (children[$-1].type == Type.Softbreak || children[$-1].type == Type.Linebreak) {
		children = children[0 .. $-1];
	}
	if (children.length == 0) {
		return;
	}
	if (children[$-1].type == Type.Text) {
		text := children[$-1].toTextFast();
		text.str = stripRight(text.str);
		if (text.slashToBreak) {
			text.str ~= "\\";
			text.slashToBreak = false;
		}
	}
	foreach (child; children) {
		text := child.toText();
		if (text !is null) {
			// escape
			text.str = text.str.replace(`\>`, ">");
		}
	}
}

fn parseThematicBreak(ref p: Parser, ref line: Line)
{
	if (line.empty) {
		return;
	}

	if (line.leadingWhitespace >= CODE_INDENT) {
		return;
	}

	tmpLine := line;
	tmpLine.consumeWhitespace();
	thematicChar: dchar;
	foreach (c: dchar; tmpLine.toString()) {
		switch (c) {
		case '-': thematicChar = '-'; break;
		case '*': thematicChar = '*'; break;
		case '_': thematicChar = '_'; break;
		default:
			return;
		}
		break;
	}

	count: size_t;
	foreach (c: dchar; tmpLine.toString()) {
		if (c == thematicChar) {
			count++;
		} else if (c != ' ' && c != '\r' && c != '\n' && c != '\t') {
			return;
		}
	}

	if (count >= 3) {
		if (p.parent().children.length > 0) {
			p.popAll();
		}
		p.parent().children.addThematicBreak();
		line.clear();
	}
}

fn parseListChild(ref p: Parser, ref line: Line) bool
{
	list := p.list();
	if (list is null) {
		return false;
	}
	assert(!line.empty);
	_lazy := isLazyContinuation(ref p, line.toString());// && line.unchanged;
	if (line.leadingWhitespace < list.delimiter.length + list.leadingWhitespace && line.iterationCount == 0 &&
		!_lazy) {
		p.pop(Type.List);
		nlist := p.list();
		if (nlist !is null) {
			nlist.blankLinePending = list.blankLinePending;
		}
		return false;
	}
	if (line.iterationCount > 0) {
		return false;
	}
	if (list.blankLinePending && p.count(Type.List) > 1) {
		// Blank lines in nested sublists don't affect the parent lists, so ensure they're not inherited.
		list.isTight = list.blankLinePending = false;
	}
	if (!_lazy || line.leadingWhitespace - min(line.leadingWhitespace, list.leadingWhitespace) >= CODE_INDENT) {
		line.advance(list.delimiter.length + list.leadingWhitespace);
	}
	return true;
}

fn parseList(ref p: Parser, ref line: Line) bool
{
	if (line.empty) {
		return false;
	}

	tmpLine := line;
	leadingWhitespace := tmpLine.consumeWhitespace();
	if (tmpLine.length == 0 || (!isDigit(tmpLine[0]) && tmpLine[0] != '-' && tmpLine[0] != '+' && tmpLine[0] != '*')) {
		return parseListChild(ref p, ref line);
	}
	cb := p.codeblock();
	list := p.list();
	if (cb !is null || (leadingWhitespace >= CODE_INDENT && list is null)) {
		return false;
	}
	ol := isDigit(tmpLine[0]);
	digitString: string;
	digitSeparator: char;

	simpleDelimiter: string;
	i: size_t;
	if (ol) {
		while (i < tmpLine.length && isDigit(tmpLine[i])) {
			i++;
		}
		digitString = tmpLine.slice(0, i);
		if (digitString.length < 1 || digitString.length >= 10) {
			return false;
		}
		if (i >= tmpLine.length || (tmpLine[i] != '.' && tmpLine[i] != ')')) {
			return false;
		}
		digitSeparator = tmpLine[i];
		simpleDelimiter = format("%s%s ", digitString, digitSeparator);
		i++;
	} else {
		simpleDelimiter = format("%s ", tmpLine[0]);
		i = 1;
	}

	delimiter := tmpLine.slice(0, i);
	ws: size_t;
	if (i < tmpLine.length && tmpLine[i] == '\t') {
		ws = 1;
	} else {
		ws = min(4, tmpLine.contiguousWhitespace(i));
	}
	if (ws == 0 && i < tmpLine.length) {
		return false;
	}
	delimiter ~= emptyString(ws);
	if (tmpLine.contiguousWhitespace(i) - 1 >= CODE_INDENT) {
		// This is the case "5.2 2: "items starting with indented code"
		tmpLine.advance(i+1);
		delimiter = tmpLine.slice(0, i+1);
	} else {
		tmpLine.advance(delimiter.length);
	}

	empty := false;
	tmpTmpLine := tmpLine;
	if (tmpLine.toString().length == 0) {
		if (list is null && p.peek() !is null && p.peek().type == Type.Paragraph) {
			// Empty list items cannot interrupt paragraphs.
			return false;
		}
		empty = true;
		delimiter = simpleDelimiter;
		tmpLine = tmpTmpLine;
	}

	item := p.item();

	invalidList := false;
	if (item !is null && ol) {
		invalidList = list.separator != digitSeparator || leadingWhitespace >= item.childPoint || tmpLine.listCount > 0;
	} else if (item !is null) {
		invalidList = list.delimiter != delimiter || leadingWhitespace >= item.childPoint || tmpLine.listCount > 0;
	}

	if (list is null || invalidList) {
		if (item !is null && leadingWhitespace < item.childPoint && tmpLine.listCount == 0) {
			p.pop(Type.List);
		}
		if (list !is null && list.blankLinePending) {
			list.isTight = false;
		}
		par := p.paragraph();
		if (par !is null) {
			if (ol && digitString != "1") {
				return false;
			}
			p.pop(Type.Paragraph);
		}
		list = p.parent().children.addList();
		list.isTight = true;
		list.delimiter = delimiter;
		list.empty = empty;
		list.leadingWhitespace = line.leadingWhitespace;
		tmpLine.listCount++;
		if (ol) {
			list.kind = List.Ordered;
			list.start = toInt(digitString);
			list.separator = digitSeparator;
		}

		p.push(list);
	} else {
		lists := p.count(Type.List);
		if (lists <= 1) {
			p.pop();
		} else {
			lastItem := list.children[$-1].toItem();
			if (lastItem is null || leadingWhitespace + delimiter.length >= lastItem.childPoint) {
				p.pop();
			} else {
				oldpending := list.blankLinePending;
				p.pop(Type.List);
				list = p.list();
				if (list !is null) {
					list.blankLinePending = oldpending;
				}
			}
		}
	}

	item = list.children.addItem();
	item.childPoint = line.leadingWhitespace + list.delimiter.length;

	p.push(item);
	line = tmpLine;
	return true;
}

fn parseCodeBlock(ref p: Parser, ref line: Line)
{
	if (line.empty) {
		return;
	}
	cb := p.codeblock();
	if (line.leadingWhitespace < CODE_INDENT && cb is null) {
		return;
	}

	if (cb !is null && line.leadingWhitespace < CODE_INDENT) {
		if (strip(line.toString()).length > 0) {
			if (p.peek() !is null && p.peek().type == Type.CodeBlock) {
				p.pop();
			}
			return;
		}
	}

	par := p.paragraph();
	bq := p.blockquote();
	if (par !is null || (bq !is null && bq.children.length != 0)) {
		return;
	}

	line.advance(CODE_INDENT);
	if (cb is null) {
		content := line.toString();
		if (strip(content).length == 0) {
			content = "";
		}
		cb = p.parent().children.addCodeBlock(content, "");

		p.push(cb);
	} else {
		if (cb.str.length > 0) {
			cb.str ~= "\n";
		}
		cb.str ~= line.toString();
	}
	list := p.list();
	if (list !is null && list.blankLinePending) {
		list.isTight = false;
	}
	line.clear();
}

fn parseAtxHeading(ref p: Parser, ref line: Line)
{
	if (line.empty) {
		return;
	}
	if (line.leadingWhitespace >= CODE_INDENT) {
		return;
	}
	tmpLine := line;

	if (tmpLine.slice(0, 2) == `\#`) {
		// escape
		tmpLine.advance(1);
		return;
	}

	tmpLine.consumeWhitespace();
	count: size_t;
	while (tmpLine.consumeChar('#')) {
		count++;
	}
	if (count > 6 || count == 0 || tmpLine.length > 0 && !isWhite(tmpLine[0])) {
		return;
	}

	lstr := tmpLine.toString();
	lstr = stripRight(lstr);
	if (lstr.length > 0) {
		taili := lstr.length - 1;
		while (taili > 0 && lstr[taili] == '#') {
			taili--;
			if (lstr[taili] != '#' && !isWhite(lstr[taili])) {
				taili = lstr.length - 1;
				break;
			}
		}
		lstr = replace(strip(lstr[0 .. taili+1]), `\#`, `#`);
	}

	line.set(lstr, 0);

	if (p.peek() !is null && p.peek().type == Type.Paragraph) {
		p.pop();
	}
	heading := p.parent().children.addHeading(cast(u32)count);

	p.push(heading);

	p.parent().children.addText(line.toString());
	line.clear();

	p.pop();
}

/*!
 * Basically, in non-spec-ese, a lazy continuation line
 * is a line that would just be parsed as a paragraph.
 * Not a list, not a quote, etc.
 * (It's lazy because it acts as if the block structure indicator
 * was written before it).
 * Very incomplete atm.
 */
fn isLazyContinuation(ref p: Parser, str: string) bool
{
	if (p.mLastLineBlank) {
		return false;
	}

	if (countLeadingWhitespace(str) >= CODE_INDENT) {
		// A codeblock cannot interrupt a paragraph, so this is an LCL.
		return true;
	}
	sstr := strip(str);
	if (sstr.length == 0) {
		return false;
	}
	switch (sstr[0]) {
	case '-', '*', '+', '>', '`': return false;
	default: return true;
	}
}

fn parseBlockQuote(ref p: Parser, ref line: Line)
{
	fn popExistingBQ()
	{
		bq := p.blockquote();
		if (bq !is null) {
			p.pop(Type.BlockQuote);
			list := p.list();
			if (list !is null) {
				list.blankLinePending = false;
			}
		}
	}

	if (line.empty) {
		popExistingBQ();
		return;
	}
	cb := p.codeblock();
	bq := p.blockquote();
	if (line.leadingWhitespace >= CODE_INDENT && bq is null) {
		popExistingBQ();
		return;
	}

	if (p.mCodeFence.length > 0 && bq is null) {
		return;
	}
	tmpLine := line;
	tmpLine.consumeWhitespace();
	if (tmpLine.length == 0 || tmpLine[0] != '>') {
		if (!isLazyContinuation(ref p, line.toString()) && line.unchanged) {
			popExistingBQ();
		}
		if ((bq !is null && cb !is null ||
			(bq !is null && bq.lastLineBlank))) {
			/* Because removing the '> ' changes the exact meaning
			 * of a codeblock, we can't lazily continue it, so close
			 * the BQ here.
			 */
			popExistingBQ();
		}
		bq = p.blockquote();
		return;
	}

	if (bq is null && p.peek() !is null && p.peek().type == Type.Paragraph) {
		// blockquotes can interrupt paragraphs
		p.pop();
	}

	bqCount := p.count(Type.BlockQuote);
	depth: size_t = 1;
	first := tmpLine.iterationCount == 0;
	while (tmpLine.length > 0 && tmpLine[0] == '>') {
		if (tmpLine.length >= 2 && isWhite(tmpLine[1])) {
			tmpLine.advance(2);
		} else {
			tmpLine.advance(1);
		}
		if (bq !is null && strip(tmpLine.toString()).length == 0 &&
			p.peek() !is null && p.peek().type == Type.Paragraph) {
			p.pop();
		}
		line = tmpLine;
		if ((bq is null || !first) && (depth + line.iterationCount > bqCount)) {
			bq = p.parent().children.addBlockQuote();

			p.push(bq);
		}
		depth++;
		first = false;
		tmpLine.consumeWhitespace();
	}

	bq.lastLineBlank = line.toString().length == 0;
	if (bq.lastLineBlank) {
		parseEmpty(ref p, ref line, true);
		p.mLastLineBlank = true;
		p.mForceBlank = true;
	}
}

fn parseCodeFence(ref p: Parser, ref line: Line)
{
	if (p.mHtml !is null) {
		return;
	}

	leadingWhitespace := line.leadingWhitespace;
	if (p.mCodeFence != "") {
		sstr := strip(line.toString());
		count: size_t;
		foreach (c: dchar; sstr) {
			if (c == p.mCodeFence[0]) {
				count++;
			} else {
				count = 0;
				break;
			}
		}
		if (count >= p.mCodeFence.length && leadingWhitespace < 4) {
			p.mExplicitlyClosedCodeFence = true;
			p.pop(Type.CodeBlock);
			line.clear();
			return;
		}
		cb := p.codeblock();
		if (line.leadingWhitespace >= cb.fenceIndentation) {
			line.advance(cb.fenceIndentation);
		} else {
			line.consumeWhitespace();
		}
		cb.str ~= line.toString() ~ "\n";
		line.clear();
		return;
	}

	if (leadingWhitespace >= CODE_INDENT) {
		return;
	}

	sstr := stripLeft(line.toString());
	if (sstr.length == 0) {
		return;
	}
	if (sstr[0] != '`' && sstr[0] != '~') {
		return;
	}
	fencec := sstr[0];
	count: size_t;
	foreach (c: dchar; sstr) {
		if (c != fencec) {
			break;
		}
		count++;
	}
	if (count < 3) {
		return;
	}

	info := "";
	if (count < sstr.length) {
		info = strip(sstr[count .. $]);
		if (info.indexOf("`") >= 0) {
			return;
		}
	}

	p.mCodeFence = uniformString(count, fencec);
	if (p.peek() !is null && p.peek().type == Type.Paragraph) {
		p.pop();
	}
	cb := p.parent().children.addCodeBlock("", htmlEntityEscape(info));
	cb.fenceIndentation = leadingWhitespace;

	list := p.list();
	if (list !is null && line.iterationCount > 0) {
		cb.fenceIndentation += list.delimiter.length;
	}

	p.push(cb);
	line.clear();
	return;
}

fn parseLinkReference(ref p: Parser, ref line: Line)
{
	str := line.toString();

	fn notReference()
	{
		p.invalidateLinkReference();
		line.clear();
	}

	sstr := stripLeft(str);
	if (p.mLinkReference !is null && sstr.length > 0 && sstr[0] == '[') {
		p.addLinkReference();
	}

	if (p.mLinkReference is null) {
		leadingWhitespace := countLeadingWhitespace(str);
		if (leadingWhitespace >= 4) {
			return;
		}
		par := p.paragraph();
		if (par !is null) {
			return;
		}

		if (sstr.length == 0 || sstr[0] != '[') {
			return;
		}

		p.mLinkReference = new LinkReference();
	} else if (p.mLinkReference !is null && sstr.length == 0) {
		if (p.mLinkReference.stage == LinkReference.Stage.Title && p.mLinkReference.title == "") {
			// Titles can be omitted.
			sstr = "";
			p.mLinkReference.stage = LinkReference.Stage.Done;
		} else {
			notReference();
			p.pop();  // Blank line closes paragraphs.
			return;
		}
	}

	p.mLinkReference.lines ~= str;
	while (sstr.length != 0) {
		final switch (p.mLinkReference.stage) with (LinkReference.Stage) {
		case Opening:
			if (!consumeChar(ref sstr, '[')) {
				return;
			}
			p.mLinkReference.stage = Label;
			break;
		case Label:
			consumeWhitespace(ref sstr);
			if (sstr.length == 0) {
				break;
			}
			labelStr: string;
			found := consumeUntilChar(ref sstr, out labelStr, ']');
			if (!found) {
				p.mLinkReference.label ~= labelStr ~ " ";
				break;
			}
			p.mLinkReference.label ~= labelStr;
			p.mLinkReference.stage = ClosingColon;
			break;
		case ClosingColon:
			consumeWhitespace(ref sstr);
			if (sstr.length == 0) {
				break;
			}
			if (!consumeChar(ref sstr, ']') || !consumeChar(ref sstr, ':')) {
				return notReference();
			}
			p.mLinkReference.stage = Url;
			break;
		case Url:
			consumeWhitespace(ref sstr);
			if (sstr.length == 0) {
				break;
			}
			if (!consumeUrl(ref sstr, out p.mLinkReference.url)) {
				return;
			}
			p.mLinkReference.url = urlEscape(markdownEscape(htmlEntityEscape(p.mLinkReference.url)));
			p.mLinkReference.stage = Title;
			break;
		case Title:
			l := p.mLinkReference;
			if (l.titleSentinel != '\'' && l.titleSentinel != '\"') {
				consumeWhitespace(ref sstr);
				if (sstr.length == 0) {
					break;
				}
				if (sstr[0] != '\'' && sstr[0] != '"') {
					/* A title without ' or ", so not a title at all. Add the link,
					 * then process this line as normal.
					 */
					l.stage = Done;
					p.addLinkReference();
					return;
				}
				l.titleSentinel = sstr[0];
				sstr = sstr[1 .. $];
			}

			i: size_t;
			while (i < sstr.length && sstr[i] != l.titleSentinel) {
				i++;
				if (i < sstr.length-2 && sstr[i] == '\\' && isPunctuation(sstr[i+1])) {
					sstr = sstr[0 .. i] ~ sstr[i+1 .. $];
					i += 2;
				}
			}
			if (i < sstr.length && sstr[i] == l.titleSentinel) {
				l.stage = Done;
			}
			l.title ~= htmlEscape(htmlEntityEscape(sstr[0 .. i]));
			if (l.stage != Done) {
				l.title ~= "\n";
			}
			sstr = sstr[i .. $];
			if (sstr.length > 0) {
				sstr = sstr[1 .. $];
			}
			consumeWhitespace(ref sstr);
			if (sstr.length != 0 && l.lines.length == 1) {
				return notReference();
			} else if (sstr.length != 0) {
				/* [foo]: /url "hi" ok  <-- verboten
				 * [foo]: /url
				 * "hi" ok <-- link reference with paragraph after it. (you are here)
				 */
				l.stage = Done;
				p.addLinkReference();
				return;
			}
			break;
		case Done:
			sstr = "";
			break;
		}
	}

	line.clear();

	if (p.mLinkReference.stage != LinkReference.Stage.Done) {
		return;
	}

	p.addLinkReference();

	return;
}

fn parseParagraph(ref p: Parser, ref line: Line)
{
	if (line.empty) {
		return;
	}
	list := p.list();
	if (list !is null && list.blankLinePending) {
		list.isTight = false;
	}
	str := line.toString();
	if (strip(str).length == 0) {
		// Ignore blank lines.
		line.clear();
		return;
	}
	par := p.paragraph();
	txt: Text;
	if (par is null) {
		par = p.parent().children.addParagraph();
		p.push(par);
		txt = par.children.addText("");
	} else {
		assert(par.children.length == 1);
		txt = par.children[0].toTextFast();
		txt.str ~= "\n";
	}
	line.consumeWhitespace();
	txt.str ~= line.toString();
	line.clear();
}
