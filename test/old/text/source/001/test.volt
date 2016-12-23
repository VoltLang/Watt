//T compiles:yes
//T retval:0
module test;

import watt.text.source;

enum string file = "hello.txt";
enum string test = "Hello\n\tWorld";

enum string utf = "ウィキペディアは";

int main()
{
	SimpleSource s;
	Source src = new Source(test, file);

	s.source = test;

	if (s.front != 'H' || s.following != 'e') {
		return 1;
	}

	if (src.front != 'H' || src.following != 'e') {
		return 2;
	}

	size_t i;

	// Check length
	for (i = 0; !s.empty; i++, s.popFront()) {}
	if (i != 12) { return 3; }

	for (i = 0; !src.empty; i++, src.popFront()) {}
	if (i != 12) { return 4; }

	// Check location.
	if (src.loc.line != 2 || src.loc.column != 7) {
		return 5;
	}

	// Utf 8 length
	s.source = utf;
	for (i = 0; !s.empty; i++, s.popFront()) {}
	if (i != 8) { return 6; }

	return 0;
}
