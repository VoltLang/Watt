// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.conv;

// The type suffixes will go away when we get function overloading.

const(char)[] toStringi(int i)
{
	size_t index = 0u;
	auto buf = new char[](11);  // 11 == maximum length of an integer, −2147483647
	bool negative = i < 0;
	if (negative) {
		i = i * -1;
	}
	
	bool inLoop = true;
	while (inLoop) {
		int remainder = i % 10;
		i = i / 10;
		buf[index++] = cast(char)(cast(int)'0' + remainder);
		inLoop = i != 0;
	}
	if (negative) {
		buf[index++] = '-';
	}
	buf.length = index;

	auto outbuf = new char[](11);
	size_t bindex = index;
	size_t oindex = 0u;
	while (oindex != index) {
		bindex--;
		outbuf[oindex] = buf[bindex];
		oindex++;
	}
	outbuf.length = oindex;

	return outbuf;
}
