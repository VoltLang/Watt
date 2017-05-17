module test;

import watt.path;

fn main() i32
{
	version (Windows) {
		if (baseName("foo\\bar.bang") != "bar.bang") {
			return 4;
		} else if (baseName("foo\\bar.bang", ".bang") != "bar") {
			return 1;
		} else if (baseName("foo\\bar\\") != "bar") {
			return 2;
		} else if (baseName("e:bang.baz") != "bang.baz") {
			return 3;
		}
	} else {
		if (baseName("foo/bar.bang") != "bar.bang") {
			return 4;
		} else if (baseName("foo/bar.bang", ".bang") != "bar") {
			return 1;
		} else if (baseName("foo/bar/") != "bar") {
			return 2;
		}
	}
	return 0;
}
