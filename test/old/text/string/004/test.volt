//T compiles:yes
//T retval:1
module test;

import watt.text.string;

int main()
{
	return cast(int)indexOf(["aa", "bb", "cc"], "bb");
}
