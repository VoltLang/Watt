module test;

import watt.io;
import watt.text.path;

version (!Windows) {
global cleantests: string[][] = [
	// Already clean
	["", "."],
	["abc", "abc"],
	["abc/def", "abc/def"],
	["a/b/c", "a/b/c"],
	[".", "."],
	["..", ".."],
	["../..", "../.."],
	["../../abc", "../../abc"],
	["../.bin/foo", "../.bin/foo"],
	["/abc", "/abc"],
	["/", "/"],

	// Remove trailing slash
	["abc/", "abc"],
	["abc/def/", "abc/def"],
	["a/b/c/", "a/b/c"],
	["./", "."],
	["../", ".."],
	["../../", "../.."],
	["/abc/", "/abc"],

	// Remove doubled slash
	["abc//def//ghi", "abc/def/ghi"],
	["//abc", "/abc"],
	["///abc", "/abc"],
	["//abc//", "/abc"],
	["abc//", "abc"],

	// Remove . elements
	["abc/./def", "abc/def"],
	["/./abc/def", "/abc/def"],
	["abc/.", "abc"],

	// Remove .. elements
	["abc/def/ghi/../jkl", "abc/def/jkl"],
	["abc/def/../ghi/../jkl", "abc/jkl"],
	["abc/def/..", "abc"],
	["abc/def/../..", "."],
	["/abc/def/../..", "/"],
	["abc/def/../../..", ".."],
	["/abc/def/../../..", "/"],
	["abc/def/../../../ghi/jkl/../../../mno", "../../mno"],
	["./../.bin/foo", "../.bin/foo"],

	// Combinations
	["abc/./../def", "def"],
	["abc//./../def", "def"],
	["abc/../../././../def", "../../def"],
];
} else {
global cleantests: string[][] = [
	// Already clean
	["", "."],
	["abc", "abc"],
	["abc\\def", "abc\\def"],
	["a\\b\\c", "a\\b\\c"],
	[".", "."],
	["..", ".."],
	["..\\..", "..\\.."],
	["..\\..\\abc", "..\\..\\abc"],
	["..\\.bin\\foo", "..\\.bin\\foo"],
	["\\abc", "\\abc"],
	["\\", "\\"],

	// Remove trailing slash
	["abc\\", "abc"],
	["abc\\def\\", "abc\\def"],
	["a\\b\\c\\", "a\\b\\c"],
	[".\\", "."],
	["..\\", ".."],
	["..\\..\\", "..\\.."],
	["\\abc\\", "\\abc"],

	// Remove doubled slash
	["abc\\\\def\\\\ghi", "abc\\def\\ghi"],
	["\\\\abc", "\\abc"],
	["\\\\\\abc", "\\abc"],
	["\\\\abc\\\\", "\\abc"],
	["abc\\\\", "abc"],

	// Remove . elements
	["abc\\.\\def", "abc\\def"],
	["\\.\\abc\\def", "\\abc\\def"],
	["abc\\.", "abc"],

	// Remove .. elements
	["abc\\def\\ghi\\..\\jkl", "abc\\def\\jkl"],
	["abc\\def\\..\\ghi\\..\\jkl", "abc\\jkl"],
	["abc\\def\\..", "abc"],
	["abc\\def\\..\\..", "."],
	["\\abc\\def\\..\\..", "\\"],
	["abc\\def\\..\\..\\..", ".."],
	["\\abc\\def\\..\\..\\..", "\\"],
	["abc\\def\\..\\..\\..\\ghi\\jkl\\..\\..\\..\\mno", "..\\..\\mno"],
	[".\\..\\.bin\\foo", "..\\.bin\\foo"],

	// Combinations
	["abc\\.\\..\\def", "def"],
	["abc\\\\.\\..\\def", "def"],
	["abc\\..\\..\\.\\.\\..\\def", "..\\..\\def"],

	// Normalise
	["abc/def", "abc\\def"],
	["a/b\\c", "a\\b\\c"],
	["foo\\.\\bar", "foo\\bar"],
	["XX:\\abc\\def\\..\\..\\..", "XX:\\"],
	["C:\\abc\\def\\..\\..\\..", "C:\\"],
];
}

fn main() i32
{
	foreach (cleantest; cleantests) {
		if (normalizePath(cleantest[0]) != cleantest[1]) {
			writefln("input \"%s\" expected \"%s\" got \"%s\"", cleantest[0], cleantest[1], normalizePath(cleantest[0]));
			return 1;
		}
	}
	return 0;
}
