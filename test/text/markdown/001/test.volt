module test;

import io = watt.io;

import watt.text.diff;
import watt.text.markdown;


global ok: i32;
global counter: i32;

fn test(src: string, expect: string)
{
	counter++;

	ret := filterMarkdown(src);
	if (ret == expect) {
		return;
	}

	ok = counter;
	io.output.writefln("test %s failed", counter);
	diff(expect, ret);
	io.output.flush();
}

fn main() i32
{
	test("![alt](http://example.org/image)",
		"<p><img src=\"http://example.org/image\" alt=\"alt\">\n</p>\n");
	test("![alt](http://example.org/image \"Title\")",
		"<p><img src=\"http://example.org/image\" alt=\"alt\" title=\"Title\">\n</p>\n");
// Supporting this would involve quite a bit of rewrite work -- leaving it for now. -BAH
//	test("their [install\ninstructions](<http://www.brew.sh>) and",
//		"<p>their <a href=\"http://www.brew.sh\">install\ninstructions</a> and\n</p>\n");
	test("[![Build Status](https://travis-ci.org/rejectedsoftware/vibe.d.png)](https://travis-ci.org/rejectedsoftware/vibe.d)",
		"<p><a href=\"https://travis-ci.org/rejectedsoftware/vibe.d\"><img src=\"https://travis-ci.org/rejectedsoftware/vibe.d.png\" alt=\"Build Status\"></a>\n</p>\n");
	test("\tthis\n\tis\n\tcode",
		"<pre><code>this\nis\ncode\n</code></pre>");
	test("    this\n    is\n    code",
		"<pre><code>this\nis\ncode\n</code></pre>");
	test("    this\n    is\n\tcode",
		"<pre><code>this\nis\ncode\n</code></pre>");
	test("\tthis\n\n\tcode",
		"<pre><code>this\n\ncode\n</code></pre>");
	test("    > this",
		"<pre><code>&gt; this\n</code></pre>");
	test(">     this",
		"<blockquote><pre><code>this\n</code></pre></blockquote>\n");
	test(">     this\n    is code",
		"<blockquote><pre><code>this\n</code></pre></blockquote>\n<pre><code>is code\n</code></pre>");
	test("[A B C][ABC]\n\n[ABC]: a_link.com",
		"<p><a href=\"a_link.com\">A B C</a>\n</p>\n");
	return ok;
}
