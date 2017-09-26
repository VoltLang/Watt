// Copyright © 2016-2017, Jakob Bornecrantz.
// See copyright notice in src/watt/license.volt (BOOST ver. 1.0).
/*!
 * Modules that generate hashes of data.
 *
 * The modules in this package hash arbitrary amounts of data
 * into integers. This is useful in implementating 'hash tables';
 * mapping between pieces of data, verification that data received
 * over a network or other unreliable transmission medium is correct.
 *
 * Please note that while hashes can be useful in cryptological contexts,
 * none of Watt's hash functions are considered usable for that task,
 * and we strongly against recommend using them in such situations.
 *
 * The hash functions all take the form of functions with the signature
 * `hashSomethingSomething(scope const(void)[])`, and returning some
 * width of unsigned integer.
 *
 * A `void[]` is an array that points to data of an unknown type, and its
 * length represents the size of the data in bytes.
 *
 * If you have an array (say a `string`), you can easily convert to a
 * `void[]` by `cast`ing it, and then pass that into the hashing function
 * of your choice:
 *
 *     hashVal := hashFNV1A_32(cast(void[])"hello");
 *
 * This will hash the string `hello` using the FNV1A algorithm, returning
 * an unsigned integer of 32 bytes: a `u32`. Anytime that same string is
 * passed to the same variant of the same hashing algorithm, it will generate
 * the same hash.  
 * Note that while hashes are designed to minimise collisions (different input
 * returning the same hash value), they can't eliminate them entirely, and
 * your code should take them into account.
 *
 * If you have data in the form of a `struct`, you can still hash it with
 * relative ease. Simply slice a pointer to the struct instance, using
 * `0` and the size of the struct in bytes:
 *
 *     myStruct: MyStruct;
 *     hashVal := hashMurmur_32((cast(void*)&myStruct)[0 .. typeid(MyStruct).size]);
 */
module watt.digest;

public import watt.digest.fnv;
public import watt.digest.murmur;
