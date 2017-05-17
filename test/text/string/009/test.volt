module test;

import core.exception;
import watt.text.string;

fn main() i32
{
	src: string = "apple pie";
	if (replace(src, "apple", "mince") != "mince pie" || src != "apple pie") {
		return 1;
	}
	if (replace("christmas tree", "tree", "tree") != "christmas tree") {
		return 2;	
	}
	if (replace("このテストは悪いですよ。", "悪い", "良い") != "このテストは良いですよ。") {
		return 3;
	}
	if (replace("", "apple", "banana") != "") {
		return 4;
	}
	return 0;
}
