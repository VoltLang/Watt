//T compiles:yes
//T retval:13
module test;

import watt.path;

int main()
{
	version (Windows) {
		if (baseName("foo\\bar.bang") != "bar.bang") {
			return 0;
		} else if (baseName("foo\\bar.bang", ".bang") != "bar") {
			return 1;
		} else if (baseName("foo\\bar\\") != "bar") {
			return 2;
		} else if (baseName("e:bang.baz") != "bang.baz") {
			return 3;
		}
	} else {
		if (baseName("foo/bar.bang") != "bar.bang") {
			return 0;
		} else if (baseName("foo/bar.bang", ".bang") != "bar") {
			return 1;
		} else if (baseName("foo/bar/") != "bar") {
			return 2;
		}
	}
	return 13;
}
