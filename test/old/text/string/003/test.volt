//T compiles:yes
//T retval:2
module test;

import watt.text.string;

int main()
{
	return cast(int)count("aabc", 'a') + cast(int)count("", 'd');
}
