//T compiles:yes
//T retval:0
module test;

import watt.path;

int main()
{
	assert(extension("file") is null);
	assert(extension("file.") == ".");
	assert(extension("file.ext") == ".ext");
	assert(extension("file.ext1.ext2") == ".ext2");
	assert(extension(".foo") is null);
	assert(extension(".foo.ext") == ".ext");

	return 0;
}
