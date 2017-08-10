// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Main importer for markdown parser.
module watt.markdown.ast;

import watt.text.sink : Sink;


//! The type of node.
enum Type
{
	Document,
	BlockQuote,
	List,
	Item,
	CodeBlock,
	HtmlBlock,
	Paragraph,
	Heading,
	ThematicBreak,

	Text,
	Softbreak,
	Linebreak,
	Code,
	HtmlInline,
	Emph,
	Strong,
	Link,
	Image,
}

//! Base struct for all nodes.
class Node
{
public:
	type: Type;


public:
	fn toDocument()           Document { if (type == Type.Document) { return toDocumentFast(); } else { return null; } }
	fn toBlockQuote()       BlockQuote { if (type == Type.BlockQuote) { return toBlockQuoteFast(); } else { return null; } }
	fn toList()                   List { if (type == Type.List) { return toListFast(); } else { return null; } }
	fn toItem()                   Item { if (type == Type.Item) { return toItemFast(); } else { return null; } }
	fn toCodeBlock()         CodeBlock { if (type == Type.CodeBlock) { return toCodeBlockFast(); } else { return null; } }
	fn toHtmlBlock()         HtmlBlock { if (type == Type.HtmlBlock) { return toHtmlBlockFast(); } else { return null; } }
	fn toParagraph()         Paragraph { if (type == Type.Paragraph) { return toParagraphFast(); } else { return null; } }
	fn toHeading()             Heading { if (type == Type.Heading) { return toHeadingFast(); } else { return null; } }
	fn toThematicBreak() ThematicBreak { if (type == Type.ThematicBreak) { return toThematicBreakFast(); } else { return null; } }
	fn toText()                   Text { if (type == Type.Text) { return toTextFast(); } else { return null; } }
	fn toSoftbreak()         Softbreak { if (type == Type.Softbreak) { return toSoftbreakFast(); } else { return null; } }
	fn toLinebreak()         Linebreak { if (type == Type.Linebreak) { return toLinebreakFast(); } else { return null; } }
	fn toCode()                   Code { if (type == Type.Code) { return toCodeFast(); } else { return null; } }
	fn toHtmlInline()       HtmlInline { if (type == Type.HtmlInline) { return toHtmlInlineFast(); } else { return null; } }
	fn toEmph()                   Emph { if (type == Type.Emph) { return toEmphFast(); } else { return null; } }
	fn toStrong()               Strong { if (type == Type.Strong) { return toStrongFast(); } else { return null; } }
	fn toLink()                   Link { if (type == Type.Link) { return toLinkFast(); } else { return null; } }
	fn toImage()                 Image { if (type == Type.Image) { return toImageFast(); } else { return null; } }

	fn toParent() Parent
	{
		if (type == Type.Document || type == Type.BlockQuote || type == Type.Paragraph ||
			type == Type.Heading || type == Type.Strong || type == Type.Link ||
			type == Type.Image || type == Type.Emph || type == Type.Item) {
			return toParentFast();
		} else {
			return null;
		}
	}

	fn toDocumentFast()           Document { return cast(Document)cast(void*)this; }
	fn toBlockQuoteFast()       BlockQuote { return cast(BlockQuote)cast(void*)this; }
	fn toListFast()                   List { return cast(List)cast(void*)this; }
	fn toItemFast()                   Item { return cast(Item)cast(void*)this; }
	fn toCodeBlockFast()         CodeBlock { return cast(CodeBlock)cast(void*)this; }
	fn toHtmlBlockFast()         HtmlBlock { return cast(HtmlBlock)cast(void*)this; }
	fn toParagraphFast()         Paragraph { return cast(Paragraph)cast(void*)this; }
	fn toHeadingFast()             Heading { return cast(Heading)cast(void*)this; }
	fn toThematicBreakFast() ThematicBreak { return cast(ThematicBreak)cast(void*)this; }
	fn toTextFast()                   Text { return cast(Text)cast(void*)this; }
	fn toSoftbreakFast()         Softbreak { return cast(Softbreak)cast(void*)this; }
	fn toLinebreakFast()         Linebreak { return cast(Linebreak)cast(void*)this; }
	fn toCodeFast()                   Code { return cast(Code)cast(void*)this; }
	fn toHtmlInlineFast()       HtmlInline { return cast(HtmlInline)cast(void*)this; }
	fn toEmphFast()                   Emph { return cast(Emph)cast(void*)this; }
	fn toStrongFast()               Strong { return cast(Strong)cast(void*)this; }
	fn toLinkFast()                   Link { return cast(Link)cast(void*)this; }
	fn toImageFast()                 Image { return cast(Image)cast(void*)this; }
	fn toParentFast()               Parent { return cast(Parent)cast(void*)this; }
}

/*!
 * A Parent node can have children nodes.
 */
abstract class Parent : Node
{
	children: Node[];
}

/*!
 * A Document node represents the entire markdown text.
 */
class Document : Parent
{
}

/*!
 * A Parent block from lines that start with `>`.
 */
class BlockQuote : Parent
{
	lastLineBlank: bool;
}

/*!
 * A Parent block that lists its children, either ordered or unordered.
 */
class List : Parent
{
public:
	enum Kind {
		Bullet,
		Ordered,
	}

	alias Bullet = Kind.Bullet;
	alias Ordered = Kind.Ordered;


public:
	kind: Kind;
	isTight: bool;
	blankLinePending: bool;
	leadingWhitespace: size_t;
	empty: bool;  // opens with an empty list item
	delimiter: string;
	separator: char;  // For digit lists, ) or .
	start: i32;
}

/*!
 * An element in a @ref watt.markdown.ast.List.
 */
class Item : Parent
{
public:
	childPoint: size_t;
}

/*!
 * A Block that contains text that is to be displayed as-is in a monospace font.
 */
class CodeBlock : Node
{
	str: string;
	info: string;
	fenceIndentation: size_t;
}

/*!
 * A block of raw HTML.
 */
class HtmlBlock : Node
{
public:
	// Corresponds to 1-7 to section 4.6.
	enum Kind {
		Script,
		Comment,
		Question,
		Bang,
		CData,
		Normal,
		Other,
	}

public:
	str: string;
	kind: Kind;
	parent: Parent;
}

/*!
 * A Paragraph is the simplest parent block, usually containing text.
 */
class Paragraph : Parent
{
}

/*!
 * Demarks a section with text in a special style. Can be generated in multiple ways.
 */
class Heading : Parent
{
	level: u32;
}

/*!
 * Breaks a document into sections. Rendered with an <hr> node in HTML.
 */
class ThematicBreak : Node
{
}

/*!
 * A written method of human communication.  
 *
 * The first instances are recorded at about 6000 BC.
 *
 * ### Bugs
 * - Tone is often hard to convey, meaning discussions can be more difficult than face-to-face.
 */
class Text : Node
{
	str: string;
	leadingWhitespace: size_t;
	slashToBreak: bool;
	run: string;
}

/*!
 * A newline.
 */
class Softbreak : Node
{

}

/*!
 * Harder form of break than @ref watt.markdown.ast.Softbreak, rendered with <br> in HTML.
 */
class Linebreak : Node
{
	slashBreak: bool;
}

/*!
 * Like @ref watt.markdown.ast.CodeBlock but inline.
 */
class Code : Node
{
	str: string;
}

/*!
 * An inline HTML tag.
 */
class HtmlInline : Node
{
	str: string;
}

/*!
 * First level of text emphasis. Rendered as italics.
 */
class Emph : Parent
{
}

/*!
 * Second level of text emphasis. Rendered as bold.
 */
class Strong : Parent
{
}

/*!
 * A Link to a URL.
 */
class Link : Parent
{
	url: string;
	title: string;
	fromHtml: bool;
}

/*!
 * A Link to an image, intended for inline display.
 */
class Image : Parent
{
	url: string;
	alt: string;
	title: string;
}

//! Visitor base class.
abstract class Visitor
{
	fn enter(n: Document, sink: Sink) { }
	fn leave(n: Document, sink: Sink) { }
	fn enter(n: BlockQuote, sink: Sink) { }
	fn leave(n: BlockQuote, sink: Sink) { }
	fn enter(n: List, sink: Sink) { }
	fn leave(n: List, sink: Sink) { }
	fn enter(n: Item, sink: Sink) { }
	fn leave(n: Item, sink: Sink) { }
	fn enter(n: Paragraph, sink: Sink) { }
	fn leave(n: Paragraph, sink: Sink) { }
	fn enter(n: Heading, sink: Sink) { }
	fn leave(n: Heading, sink: Sink) { }
	fn enter(n: Emph, sink: Sink) { }
	fn leave(n: Emph, sink: Sink) { }
	fn enter(n: Link, sink: Sink) { }
	fn leave(n: Link, sink: Sink) { }
	fn enter(n: Image, sink: Sink) { }
	fn leave(n: Image, sink: Sink) { }
	fn enter(n: Strong, sink: Sink) { }
	fn leave(n: Strong, sink: Sink) { }

	fn visit(n: HtmlBlock, sink: Sink) { }
	fn visit(n: CodeBlock, sink: Sink) { }
	fn visit(n: ThematicBreak, sink: Sink) { }
	fn visit(n: Text, sink: Sink) { }
	fn visit(n: Softbreak, sink: Sink) { }
	fn visit(n: Linebreak, sink: Sink) { }
	fn visit(n: Code, sink: Sink) { }
	fn visit(n: HtmlInline, sink: Sink) { }
}

//! Dispatch to correct visitor function.
fn accept(n: Node, v: Visitor, sink: Sink)
{
	switch(n.type) with (Type) {
	case Document:
		p := n.toDocumentFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case BlockQuote:
		p := n.toBlockQuoteFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case List:
		p := n.toListFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Item:
		p := n.toItemFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Paragraph:
		p := n.toParagraphFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Heading:
		p := n.toHeadingFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Emph:
		p := n.toEmphFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Link:
		p := n.toLinkFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Image:
		p := n.toImageFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case Strong:
		p := n.toStrongFast();
		v.enter(p, sink);
		foreach (c; p.children) {
			c.accept(v, sink);
		}
		v.leave(p, sink);
		break;
	case HtmlBlock:
		leaf := n.toHtmlBlockFast();
		v.visit(leaf, sink);
		break;
	case CodeBlock:
		leaf := n.toCodeBlockFast();
		v.visit(leaf, sink);
		break;
	case ThematicBreak:
		leaf := n.toThematicBreakFast();
		v.visit(leaf, sink);
		break;
	case Text:
		leaf := n.toTextFast();
		v.visit(leaf, sink);
		break;
	case Softbreak:
		leaf := n.toSoftbreakFast();
		v.visit(leaf, sink);
		break;
	case Linebreak:
		leaf := n.toLinebreakFast();
		v.visit(leaf, sink);
		break;
	case Code:
		leaf := n.toCodeFast();
		v.visit(leaf, sink);
		break;
	case HtmlInline:
		leaf := n.toHtmlInlineFast();
		v.visit(leaf, sink);
		break;
	default:
		io.error.writefln("%s", n.type);
		io.error.flush();
		assert(false);
	}
}

import io = watt.io;
