module test;

import watt.io;
import watt.digest.fnv;

fn main() i32
{
	tests: u32[string];
	tests["banana"] = 0xd9889f50_u32;
	tests["ghi"] = 0x3b285679_u32;
	tests["ZASdf"] = 0x76560b5f_u32;
	tests["#"] = 0x260c9112_u32;
	tests[""] = 0x811c9dc5_u32;
	foreach (k, v; tests) {
		if (hashFNV1A_32(cast(void[])k) != v) {
			return 1;
		}
	}
	return 0;
}
