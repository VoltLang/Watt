module test;

import watt.text.markdown;


fn main() i32
{
	if (filterMarkdown("Hello World [ this crashes")
	    != "<p>Hello World [ this crashes\n</p>\n") {
		return 1;
	}

	return 0;
}