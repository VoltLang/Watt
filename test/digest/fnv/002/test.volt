module test;

import watt.digest.fnv;

fn main() i32
{
	tests: u64[string];
	tests["banana"] = 0xb4d3b6b1c372c890_u64;
	tests["ghi"] = 0xd5084a18facb1eb9_u64;
	tests["ZASdf"] = 0x3473a9aa71894f7f_u64;
	tests["#"] = 0xaf639e4c86018332_u64;
	tests[""] = 0xcbf29ce484222325_u64;
	foreach (k, v; tests) {
		if (hashFNV1A_64(cast(void[])k) != v) {
			return 1;
		}
	}
	return 0;
}
