//T compiles:yes
//T retval:0
module test;

import watt.path;
import watt.io;

int main()
{
	if (dirName("aFile") != ".") {
		return 1;
	}
	version (Windows) {
		if (dirName("pathTo\\aFile") != "pathTo") {
			return 2;
		}
		if (dirName("\\aFile") != "\\") {
			return 3;
		}
		if (dirName("pathAnd\\aPath\\") != "pathAnd") {
			return 4;
		}
		if (dirName("D:file") != "D:") {
			return 5;
		}
		if (dirName("D:\\file") != "D:\\") {
			return 6;
		}
	} else {
		if (dirName("pathTo/aFile") != "pathTo") {
			return 2;
		}
		if (dirName("/aFile") != "/") {
			return 3;
		}
		if (dirName("pathAnd/aPath/") != "pathAnd") {
			return 4;
		}
	}
	return 0;
}

