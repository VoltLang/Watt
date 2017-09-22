module test;

import watt.digest.murmur;

fn main() i32
{
	data: u8[1025];
	foreach (i; 0 .. data.length) {
		data[i] = 0xAC;
	}

	alignedHash := hashMurmur_32(cast(void[])data[0 .. $-1]);
	unalignedHash := hashMurmur_32(cast(void[])data[1 .. $]);
	if (alignedHash != unalignedHash) {
		return 1;
	}
	return 0;
}
