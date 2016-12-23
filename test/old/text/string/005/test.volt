//T compiles:yes
//T retval:3
module test;

import watt.text.string;

int main()
{
	return cast(int)(lastIndexOf("adbcde", 'd') + lastIndexOf("", 'x'));
}
