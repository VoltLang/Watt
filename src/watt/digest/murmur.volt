// Copyright © 2017 Bernard Helyer.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
/*!
 * Contains an implementation of the Murmur hashing function.
 *
 * In particular, the 32 bit variant of the MurmurHash3 algorithm,
 * optimised for little-endian CPUs.
 *
 * Murmur hash is intended to be fast, while generating hashes
 * with good distribution and hash resistance. It is not appropriate
 * for cryptographic purposes.
 *
 * @sa [Murmur Hash's Homepage](https://github.com/aappleby/smhasher/wiki/MurmurHash3)
 */
module watt.digest.murmur;

/*!
 * Hash data using the 32 bit Murmur hash, and a seed of 0.
 *
 * @Param arr The data to hash.
 * @Return A 32 bit unsigned integer containing the calculated hash.
 */
fn hashMurmur_32(arr: scope const(void[])) u32
{
	return hashMurmur_32(arr, 0);
}

/*!
 * Hash data using the 32 bit Murmur hash, and a seed.
 *
 * @Param arr The data to hash.
 * @Param seed A value to add additional randomness to the hashing process.
 * @Return A 32 bit unsignedf integer containing the calculated hash.
 */
fn hashMurmur_32(arr: scope const(void[]), seed: u32) u32
{
	data := (cast(u8[])arr).ptr;
	len := cast(i32)arr.length;
	nblocks := len / 4;
	h1: u32 = seed;

	blocks := cast(u32*)(data + nblocks*4);

	for (i: i32 = -nblocks; i; i++)
	{
		k1: u32 = blocks[i];
		k1 *= c1_32;
		k1 = rotl32(k1,15);
		k1 *= c2_32;
		h1 ^= k1;
		h1 = rotl32(h1,13); 
		h1 = h1*5U+0xe6546b64_u32;
	}

	// Calculate the rest of the bytes that don't fit in the body.
	tail := cast(u8*)(data + nblocks*4);

	k1: u32 = 0;
	switch(len & 3) {
	case 3: k1 ^= tail[2] << 16U; goto case;
	case 2: k1 ^= tail[1] << 8U; goto case;
	case 1: k1 ^= tail[0];
          k1 *= c1_32; k1 = rotl32(k1,15); k1 *= c2_32; h1 ^= k1; goto case;
	default:
		break;
	}

	h1 ^= cast(u32)len;
	h1 = fmix32(h1);
	return h1;
} 

private:

enum c1_32 = 0xcc9e2d51_u32;
enum c2_32 = 0x1b873593_u32;

fn rotl32(x: u32, r: u8) u32
{
	return (x << r) | (x >> (32U - r));
}

fn fmix32(h: u32) u32
{
	h ^= h >> 16;
	h *= 0x85ebca6b_u32;
	h ^= h >> 13;
	h *= 0xc2b2ae35_u32;
	h ^= h >> 16;
	return h;
}
