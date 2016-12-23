//T compiles:yes
//T retval:42
module test;

import watt.text.html;


int main()
{
	if (htmlEscape(`"Hello", <World>!`) != `&quot;Hello&quot;, &lt;World&gt;!`) {
		return 1;
	}
	if (htmlEscapeAll("Hello!") != "&#72;&#101;&#108;&#108;&#111;&#33;") {
		return 2;
	}
	if (htmlEscapeIgnoreTags(`"Hello", <World>!`) != `&quot;Hello&quot;, <World>!`) {
		return 3;
	}
	return 42;
}
