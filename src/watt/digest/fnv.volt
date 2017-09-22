// Copyright © 2016-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
/*!
 * Contains two variants of the Fowler–Noll–Vo hashing function.
 *
 * FNV is a non-cryptographic hash function that produces fewer hash collisions
 * than the crc32 hashing function that is available via `vrt_hash`.
 *
 * @sa [Wikipedia](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function).
 */
module watt.digest.fnv;


/*!
 * Hash data using a 32 bit variant of the FNV hash function.
 *
 * You'll have to `cast` most data to `void[]` in order for this function
 * to accept it. Internally, it treats the data as a series of bytes.
 *
 * @Param arr The data to hash.
 * @Return A 32 bit unsigned integer with the calculated hash value.
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
 * Hash data using a 64 bit variant of the FNV hash function.
 *
 * You'll have to `cast` most data to `void[]` in order for this function
 * to accept it. Internally, it treats the data as a series of bytes.
 *
 * @Param arr The data to hash.
 * @Return A 64 bit unsigned integer with the calculated hash value.
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
