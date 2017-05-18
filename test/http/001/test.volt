module test;

import watt.http : Http, Request;
import watt.io : output;


fn main() i32
{
	http := new Http();
	req1 := new Request(http);
	req2 := new Request(http);
	// Make sure the HTTP stuff is being compiled on the CI.
/+
	req1.server = "www.google.com";
	req1.port = 80;
	req1.secure = false;
	req1.url = "";

	req2.server = "github.com";
	req2.port = 443;
	req2.secure = true;
	req2.url = "about";

	while (!http.isEmpty()) {
		http.perform();
	}

	str1 := req1.getString();
	str2 := req2.getString();
	output.writefln("Data:%s\n\n%s", str1.length, str1);
	output.writefln("Data:%s\n\n%s", str2.length, str2);
	output.writefln("Lengths %s %s", str1.length, str2.length);
+/
	return 0;
}
