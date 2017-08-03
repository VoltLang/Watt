module test;

import watt.markdown;


fn main() i32
{
	if (filterMarkdown("Hello World [ this crashes")
	    != "<p>Hello World [ this crashes</p>\n") {
		return 1;
	}

	return 0;
}
