// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Markdown HTML printer.
module watt.markdown.html;

import watt.text.format : format;
import watt.text.sink : StringSink, Sink;
import watt.text.html : htmlEscape, htmlUnescape;
import watt.text.string;
import watt.markdown.ast;


//! Print the given Markdown document in html format and return it as a string.
fn printHtml(doc: Document) string
{
	s: StringSink;
	doc.printHtml(s.sink);
	return s.toString();
}

//! Print the given Markdown document in html format to the given sink.
fn printHtml(doc: Document, sink: Sink)
{
	html := new Html();
	accept(doc, html, sink);
}

//! Prints Markdown documents in format HTML.
class Html : Visitor
{
public:
	//! Are we in plain mode. This is used for images and links.
	plain: Node;
	//! Track if the last character written was a newline.
	lastNl: bool;


private:
	mStackNum: size_t;
	mStack: Node[];
	mImageChildrenStack: Node[][];


public:
	override fn enter(n: Document, sink: Sink)
	{
		push(n);
		lastNl = true;
	}

	override fn leave(n: Document, sink: Sink)
	{
		assert(mStackNum == 1);
		pop(n);
		assert(mStackNum == 0);
		ln(sink);
	}

	override fn enter(n: BlockQuote, sink: Sink)
	{
		push(n);
		ln(sink);
		wln(sink, "<blockquote>");
	}

	override fn leave(n: BlockQuote, sink: Sink)
	{
		ln(sink);
		wln(sink, "</blockquote>");
		pop(n);
	}

	override fn enter(n: Paragraph, sink: Sink)
	{
		push(n);

		if (!isGrandparentTightList()) {
			ln(sink);
			w(sink, "<p>");
		}
	}

	override fn leave(n: Paragraph, sink: Sink)
	{
		if (!isGrandparentTightList()) {
			w(sink, "</p>");
			ln(sink);
		}

		pop(n);
	}

	override fn enter(n: Heading, sink: Sink)
	{
		push(n);
		ln(sink);
		format(sink, "<h%s>", n.level);
		lastNl = false;
	}

	override fn leave(n: Heading, sink: Sink)
	{
		format(sink, "</h%s>\n", n.level);
		lastNl = true;
		pop(n);
	}

	override fn enter(n: List, sink: Sink)
	{
		push(n);
		ln(sink);

		final switch (n.kind) with (List.Kind) {
		case Ordered:
			w(sink, "<ol");
			if (n.start != 1) {
				format(sink, " start=\"%s\"", n.start);
			}
			wln(sink, ">");
			break;
		case Bullet:
			wln(sink, "<ul>");
			break;
		}
	}

	override fn leave(n: List, sink: Sink)
	{
		ln(sink);

		final switch (n.kind) with (List.Kind) {
		case Ordered: wln(sink, "</ol>"); break;
		case Bullet: wln(sink, "</ul>"); break;
		}

		pop(n);
	}

	override fn enter(n: Item, sink: Sink)
	{
		push(n);
		ln(sink);
		w(sink, "<li>");
		lastNl = false;
	}

	override fn leave(n: Item, sink: Sink)
	{
		wln(sink, "</li>");
		pop(n);
	}

	override fn enter(n: Link, sink: Sink)
	{
		push(n);
		sink("<a");
		format(sink, " href=\"%s\"", htmlEscape(n.url));
		if (n.title != "") {
			format(sink, " title=\"%s\"", htmlEscape(htmlUnescape(n.title)));
		}
		sink(">");
		lastNl = false;
	}

	override fn leave(n: Link, sink: Sink)
	{
		sink("</a>");
		lastNl = false;
		pop(n);
	}

	override fn enter(n: Image, sink: Sink)
	{
		push(n);
		sink("<img");
		format(sink, " src=\"%s\"", n.url);
		format(sink, " alt=\"%s\"", n.alt);
		if (n.title !is null) {
			format(sink, " title=\"%s\"", n.title);
		}
		sink(" />");
		mImageChildrenStack ~= n.children;
		n.children = null;
		lastNl = false;
	}

	override fn leave(n: Image, sink: Sink)
	{
		n.children = mImageChildrenStack[$-1];
		mImageChildrenStack = mImageChildrenStack[0 .. $-1];
		pop(n);
	}

	override fn enter(n: Emph, sink: Sink)
	{
		push(n);
		w(sink, "<em>");
	}

	override fn leave(n: Emph, sink: Sink)
	{
		w(sink, "</em>");
		pop(n);
	}

	override fn enter(n: Strong, sink: Sink)
	{
		push(n);
		w(sink, "<strong>");
	}

	override fn leave(n: Strong, sink: Sink)
	{
		w(sink, "</strong>");
		pop(n);
	}

	override fn visit(n: HtmlBlock, sink: Sink)
	{
		w(sink, n.str);
	}

	override fn visit(n: CodeBlock, sink: Sink)
	{
		ln(sink);
		sink("<pre><code");
		infoWords := n.info.split(" ");
		if (infoWords.length >= 1 && infoWords[0] != "") {
			format(sink, " class=\"language-%s\">", infoWords[0]);
		} else {
			sink(">");
		}
		htmlEscape(sink, n.str, "'");
		sink("</code></pre>\n");
		lastNl = true;
	}

	override fn visit(n: Text, sink: Sink)
	{
		if (n.str.length > 0) {
			htmlEscape(sink, n.str, "'");
			lastNl = n.str[$ - 1] == '\n';
		}
	}

	override fn visit(n: Code, sink: Sink)
	{
		sink("<code>");
		htmlEscape(sink, n.str, "'");
		sink("</code>");
		lastNl = false;
	}

	override fn visit(n: HtmlInline, sink: Sink)
	{
		w(sink, n.str);
	}

	override fn visit(n: Softbreak, sink: Sink)
	{
		ln(sink);
	}

	override fn visit(n: Linebreak, sink: Sink)
	{
		wln(sink, "<br />");
	}

	override fn visit(n: ThematicBreak, sink: Sink)
	{
		ln(sink);
		wln(sink, "<hr />");
	}


	/*
	 *
	 * Helpers.
	 *
	 */
protected:
	final fn ln(sink: Sink)
	{
		if (!lastNl) {
			sink("\n");
			lastNl = true;
		}
	}

	final fn w(sink: Sink, str: string)
	{
		if (str.length) {
			lastNl = str[$ - 1] == '\n';
			sink(str);
		}
	}

	final fn wln(sink: Sink, str: string)
	{
		w(sink, str);
		ln(sink);
	}

	final fn getGrandparent() Node
	{
		if (mStackNum < 3) {
			return null;
		}

		return mStack[mStackNum - 3];
	}

	final fn isGrandparentTightList() bool
	{
		if (gp := getGrandparent()) {
			if (list := gp.toList()) {
				return list.isTight;
			}
		}
		return false;
	}

	final fn push(n: Document) { push(cast(Node)n); }
	final fn push(n: BlockQuote) { push(cast(Node)n); }
	final fn push(n: List) { push(cast(Node)n); }
	final fn push(n: Item) { push(cast(Node)n); }
	final fn push(n: Paragraph) { push(cast(Node)n); }
	final fn push(n: Heading) { push(cast(Node)n); }
	final fn push(n: Emph) { push(cast(Node)n); }
	final fn push(n: Strong) { push(cast(Node)n); }
	final fn push(n: Link) { push(cast(Node)n); }
	final fn push(n: Image) { push(cast(Node)n); }

	final fn pop(n: Document) { pop(cast(Node)n); }
	final fn pop(n: BlockQuote) { pop(cast(Node)n); }
	final fn pop(n: List) { pop(cast(Node)n); }
	final fn pop(n: Item) { pop(cast(Node)n); }
	final fn pop(n: Paragraph) { pop(cast(Node)n); }
	final fn pop(n: Heading) { pop(cast(Node)n); }
	final fn pop(n: Emph) { pop(cast(Node)n); }
	final fn pop(n: Strong) { pop(cast(Node)n); }
	final fn pop(n: Link) { pop(cast(Node)n); }
	final fn pop(n: Image) { pop(cast(Node)n); }

	final fn push(n: Node)
	{
		if (mStackNum >= mStack.length) {
			newStack := new Node[](mStack.length + 16);
			newStack[0 .. mStack.length] = mStack[..];
			mStack = newStack;
		}
		mStack[mStackNum++] = n;
	}

	final fn pop(n: Node)
	{
		if (mStackNum <= 0) {
			return;
		}
		check := mStack[--mStackNum] is n;
		assert(check);
	}
}
