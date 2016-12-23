//T compiles:yes
//T retval:10
module test;

import watt.text.markdown;

int main()
{
	assert(filterMarkdown("![alt](http://example.org/image)")
		== "<p><img src=\"http://example.org/image\" alt=\"alt\">\n</p>\n");
	assert(filterMarkdown("![alt](http://example.org/image \"Title\")")
		== "<p><img src=\"http://example.org/image\" alt=\"alt\" title=\"Title\">\n</p>\n");
// Supporting this would involve quite a bit of rewrite work -- leaving it for now. -BAH
//	assert(filterMarkdown("their [install\ninstructions](<http://www.brew.sh>) and")
//		== "<p>their <a href=\"http://www.brew.sh\">install\ninstructions</a> and\n</p>\n");
	assert(filterMarkdown("[![Build Status](https://travis-ci.org/rejectedsoftware/vibe.d.png)](https://travis-ci.org/rejectedsoftware/vibe.d)")
		== "<p><a href=\"https://travis-ci.org/rejectedsoftware/vibe.d\"><img src=\"https://travis-ci.org/rejectedsoftware/vibe.d.png\" alt=\"Build Status\"></a>\n</p>\n");
	auto res = filterMarkdown("hello\nworld", MarkdownFlags.forumDefault);
	assert(res == "<p>hello<br>world\n</p>\n", res);
	assert(filterMarkdown("\tthis\n\tis\n\tcode") ==
		"<pre><code>this\nis\ncode\n</code></pre>");
	assert(filterMarkdown("    this\n    is\n    code") ==
		"<pre><code>this\nis\ncode\n</code></pre>");
	assert(filterMarkdown("    this\n    is\n\tcode") ==
		"<pre><code>this\nis\ncode\n</code></pre>");
	assert(filterMarkdown("\tthis\n\n\tcode") ==
		"<pre><code>this\n\ncode\n</code></pre>");
	assert(filterMarkdown("    > this") ==
		"<pre><code>&gt; this\n</code></pre>");
	assert(filterMarkdown(">     this") ==
		"<blockquote><pre><code>this\n</code></pre></blockquote>\n");
	assert(filterMarkdown(">     this\n    is code") ==
		"<blockquote><pre><code>this\n</code></pre></blockquote>\n<pre><code>is code\n</code></pre>");
	return 10;
}
