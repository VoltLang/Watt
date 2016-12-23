//T compiles:yes
//T retval:17
module test;

import watt.text.utf;

int main()
{
	string s = "こんにちは";
	size_t index;
	if (decode(s, ref index) == 'こ') {
		if (decode(s, ref index) == 'ん') {
			return 17;
		}
	}
	return 2;
}
