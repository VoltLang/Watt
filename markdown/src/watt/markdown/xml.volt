// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Xml exporter of ast, used for debugging.
module watt.markdown.xml;

import watt.text.format : format;
import watt.text.sink : StringSink, Sink;
import watt.markdown.ast;


//! Print the document as a xml ast, return it as a string.
fn printXml(doc: Document) string
{
	s: StringSink;
	doc.printXml(s.sink);
	return s.toString();
}

//! Print the document as a XML AST to the given sink.
fn printXml(doc: Document, sink: Sink)
{
	xml := new Xml();
	accept(doc, xml, sink);
}

//! Pure AST XML printer for Markdown.
class Xml : Visitor
{
public:
	indent: u32;


public:
	fn enter(str: string, sink: Sink)
	{
		foreach (0 .. indent) {
			sink("  ");
		}
		sink(str);
		indent += 1;
	}

	fn leave(str: string, sink: Sink)
	{
		indent -= 1;
		foreach (0 .. indent) {
			sink("  ");
		}
		sink(str);
	}

	fn visit(str: string, sink: Sink)
	{
		foreach (0 .. indent) {
			sink("  ");
		}
		sink(str);
	}

	override fn enter(n: Document, sink: Sink)
	{
		sink("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		sink("<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n");
		enter("<document xmlns=\"http://commonmark.org/xml/1.0\">\n", sink);
	}

	override fn leave(n: Document, sink: Sink)
	{
		leave("</document>\n", sink);
	}

	override fn enter(n: BlockQuote, sink: Sink)
	{
		enter("<block_quote>\n", sink);
	}

	override fn leave(n: BlockQuote, sink: Sink)
	{
		leave("</block_quote>\n", sink);
	}

	override fn enter(n: Paragraph, sink: Sink)
	{
		enter("<paragraph>\n", sink);
	}

	override fn leave(n: Paragraph, sink: Sink)
	{
		leave("</paragraph>\n", sink);
	}

	override fn enter(n: Heading, sink: Sink)
	{
		if (n.children.length == 0) {
			visit(format("<heading level=\"%s\" />\n", n.level), sink);
			return;
		}
		enter("<heading", sink);
		format(sink, " level=\"%s\">\n", n.level);
	}

	override fn leave(n: Heading, sink: Sink)
	{
		if (n.children.length != 0) {
			leave("</heading>\n", sink);
		}
	}

	override fn enter(n: List, sink: Sink)
	{
		enter("<list", sink);
		final switch (n.kind) with (List.Kind) {
		case Ordered:
			format(sink, " type=\"ordered\"");
			format(sink, " start=\"%s\"", n.start);
			format(sink, " delim=\"%s\"", n.delimiter);
			format(sink, " tight=\"%s\"", n.isTight);
			break;
		case Bullet:
			format(sink, " type=\"bullet\"");
			format(sink, " tight=\"%s\"", n.isTight);
			break;
		}
		sink(">\n");
	}

	override fn leave(n: List, sink: Sink)
	{
		leave("</list>\n", sink);
	}

	override fn enter(n: Item, sink: Sink)
	{
		enter("<item>\n", sink);
	}

	override fn leave(n: Item, sink: Sink)
	{
		leave("</item>\n", sink);
	}

	override fn enter(n: Link, sink: Sink)
	{
		enter("<link", sink);
		format(sink, " destination=\"%s\"", n.url);
		format(sink, " title=\"%s\"", n.title);
		sink(">\n");
	}

	override fn leave(n: Link, sink: Sink)
	{
		leave("</link>\n", sink);
	}

	override fn enter(n: Image, sink: Sink)
	{
		enter("<image", sink);
		format(sink, " destination=\"%s\"", n.url);
		format(sink, " title=\"%s\"", n.title);
		sink(">\n");
	}

	override fn leave(n: Image, sink: Sink)
	{
		leave("</image>\n", sink);
	}

	override fn enter(n: Emph, sink: Sink)
	{
		enter("<emph>\n", sink);
	}

	override fn leave(n: Emph, sink: Sink)
	{
		leave("</emph>\n", sink);
	}

	override fn enter(n: Strong, sink: Sink)
	{
		enter("<strong>\n", sink);
	}

	override fn leave(n: Strong, sink: Sink)
	{
		leave("</strong>\n", sink);
	}

	override fn visit(n: HtmlBlock, sink: Sink)
	{
		visit("<html_block>", sink);
		sink(n.str); // TODO Escape
		sink("</html_block>");
	}

	override fn visit(n: CodeBlock, sink: Sink)
	{
		visit("<code_block", sink);
		if (n.info != "") {
			format(sink, " info=\"%s\">", n.info);
		} else {
			sink(">");
		}
		sink(n.str); // TODO Escape
		sink("</code_block>\n");
	}

	override fn visit(n: Text, sink: Sink)
	{
		if (n.str.length == 0) {
			return;
		}
		visit("<text>", sink);
		sink(n.str); // TODO Escape
		sink("</text>\n");
	}

	override fn visit(n: Code, sink: Sink)
	{
		visit("<code>", sink);
		sink(n.str); // TODO Escape
		sink("</code>\n");
	}

	override fn visit(n: HtmlInline, sink: Sink)
	{
		visit("<html_inline>", sink);
		sink(n.str); // TODO Escape
		sink("</html_inline>\n");
	}

	override fn visit(n: Softbreak, sink: Sink)
	{
		visit("<softbreak />\n", sink);
	}

	override fn visit(n: Linebreak, sink: Sink)
	{
		visit("<linebreak />\n", sink);
	}

	override fn visit(n: ThematicBreak, sink: Sink)
	{
		visit("<thematic_break />\n", sink);
	}
}
