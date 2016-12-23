//T compiles:yes
//T retval:8
module test;

import watt.io.file : read;

int main()
{
	auto p = read("..");
	return p !is null ? 4 : 8;
}
