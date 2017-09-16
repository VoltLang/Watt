// Copyright © 2016-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
/*!
 * Holds two variants of the Fowler–Noll–Vo hashing function.

 * It is a non-cryptographic hash function and produces fewer hash collisions
 * then crc32 hashing function available in vrt_hash.
 *
 * @sa [Wikipedia](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function).
 */
module watt.digest.fnv;


/*!
 * Fowler–Noll–Vo hash function, 32-bit variant.
 */
fn hashFNV1A_32(arr: scope const(void)[]) u32
{
	arrU8 := cast(scope const(u8)[])arr;

	h := 0x811c9dc5_u32;
	foreach (v; arrU8) {
		h = (h ^ v) * 0x1000193_u32;
	}

	return h;
}

/*!
 * Fowler–Noll–Vo hash function, 64-bit variant.
 */
fn hashFNV1A_64(arr: scope const(void)[]) u64
{
	arrU8 := cast(scope const(u8)[])arr;

	h := 0xcbf29ce484222325_u64;
	foreach (v; arrU8) {
		h = (h ^ v) * 0x100000001b3_u64;
	}

	return h;
}
