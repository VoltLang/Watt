module test;

import watt.io;
import watt.text.demangle;

global tests: string[][] = [
	["Vf4test4ichiFvZv", "fn test.ichi()"],
	["Vf4test2niFvZi", "fn test.ni() i32"],
	["Vf4test3sanFviZi", "fn test.san(i32) i32"],
	["Vf4test3yonFvsbZui", "fn test.yon(i16, i8) u32"],
	["Vf4test2goFvpvZv", "fn test.go(void*)"],
	["Vf4test4rokuFvZppc", "fn test.roku() char**"],
	["Vf4test4nanaFvacZv", "fn test.nana(char[])"],
	["Vf4test5hachiFvaocZv", "fn test.hachi(const(char)[])"],
	["Vf4test4kyuuFvamcZv", "fn test.kyuu(immutable(char)[])"],
	["Vf4test4jyuuFvAaiamcZv", "fn test.jyuu(immutable(char)[][i32])"],
	["Vf4test8jyuuichiFvat32AaiamcZv", "fn test.jyuuichi(immutable(char)[][i32][32])"],
	["Vf4test6jyuuniFvFviZiZv", "fn test.jyuuni(fn(i32) i32)"],
	["Vf4test7jyuusanFvDviZsZv", "fn test.jyuusan(dg(i32) i16)"],
	["Vf4test7jyuuyonFvS4test4DataZv", "fn test.jyuuyon(test.Data)"],
	["Vf4test6jyuugoFvriZv", "fn test.jyuugo(ref i32)"],
	["Vf4test8jyuurokuFvOiZv", "fn test.jyuuroku(out i32)"],
	["Vf4test8jyuunanaFveiZv", "fn test.jyuunana(scope(i32))"],
	["Vf4test3Foo9jyuuhachiMFvZv", "fn test.Foo.jyuuhachi()"],
	["Vf4test8jyuukyuuFvaBat12BZv", "fn test.jyuukyuu(bool[], bool[12])"],
];

global shortTests: string[][] = [
	["Vf4test4ichiFvZv", "fn test.ichi()"],
	["Vf4test2niFvZi", "fn test.ni() i32"],
	["Vf4test3sanFviZi", "fn test.san(i32) i32"],
	["Vf4test3yonFvsbZui", "fn test.yon(i16, i8) u32"],
	["Vf4test2goFvpvZv", "fn test.go(void*)"],
	["Vf4test4rokuFvZppc", "fn test.roku() char**"],
	["Vf4test4nanaFvacZv", "fn test.nana(char[])"],
	["Vf4test5hachiFvaocZv", "fn test.hachi(const(char)[])"],
	["Vf4test4kyuuFvamcZv", "fn test.kyuu(string)"],
	["Vf4test4jyuuFvAaiamcZv", "fn test.jyuu(string[i32])"],
	["Vf4test8jyuuichiFvat32AaiamcZv", "fn test.jyuuichi(string[i32][32])"],
	["Vf4test6jyuuniFvFviZiZv", "fn test.jyuuni(fn(i32) i32)"],
	["Vf4test7jyuusanFvDviZsZv", "fn test.jyuusan(dg(i32) i16)"],
	["Vf4test7jyuuyonFvS4test4DataZv", "fn test.jyuuyon(Data)"],
	["Vf4test6jyuugoFvriZv", "fn test.jyuugo(ref i32)"],
	["Vf4test8jyuurokuFvOiZv", "fn test.jyuuroku(out i32)"],
	["Vf4test8jyuunanaFveiZv", "fn test.jyuunana(scope(i32))"],
	["Vf4test3Foo9jyuuhachiMFvZv", "fn test.Foo.jyuuhachi()"],
	["Vf4test8jyuukyuuFvI4test3FooZv", "fn test.jyuukyuu(Foo)"],
];

fn main() i32
{
	foreach (i, test; tests) {
		result := demangle(test[0]);
		if (result != test[1]) {
			writefln("Test %s '%s' failure. Got '%s', expected '%s'.",
				i+1, test[0], result, test[1]);
			return 1;
		}
	}
	foreach (i, test; shortTests) {
		result := demangleShort(test[0]);
		if (result != test[1]) {
			writefln("Short test %s '%s' failure. Got '%s', expected '%s'.",
				i+1, test[0], result, test[1]);
			return 1;
		}
	}
	return 0;
}
