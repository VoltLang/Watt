// Copyright © 2015-2016, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * A psuedo-random number generator.
 *
 * A [psuedorandom number generator](https://en.wikipedia.org/wiki/Pseudorandom_number_generator)
 * generates a sequence of numbers.  
 * The numbers give the impression of randomness, and will be uniformly distributed.  
 * The generator in this module is instanced, not global. That is to say, you declare a `struct`,
 * and it holds the RNG state:
 * ```volt
 * rng: RandomGenerator;
 * rng.seed(32);
 * val := rnd.uniformI32(0, 100);
 * ```
 * Given the same seed, a RNG should generate the same sequence of numbers. Often, the output of
 * the C library function `time` is used to get a random seed value, but this is not ideal.
 * Operating Systems usually provide hardware randomness, or at least stronger randomness, and
 * using that generator to get a seed value is recommended.  
 * See the module @ref watt.io.seed for a function for retrieving a value for the seed.
 */
module watt.math.random;


//! Default `RandomGenerator`.
alias RandomGenerator = MersenneTwisterEngine;

// Adapted from Phobos's std.random.

/*!
 * A generator implemented with the [Mersenne Twister](https://en.wikipedia.org/wiki/Mersenne_Twister)
 * algorithm.
 */
struct MersenneTwisterEngine
{
public:
	//! The smallest unsigned value this generator can generate.
	enum u32 min = 0;
	//! The largest unsigned value this generator can generate.
	// u32.max >>> (uint.sizeof * 8 - w)
	enum u32 max = 0xFFFFFFFFU;//_FFFFFFFFU;

private:
	enum u32 MT_W = 32U;
	enum u32 MT_SZ = 4U;
	enum u32 MT_N = 624U;
	enum u32 MT_M = 397U;
	enum u32 MT_R = 31U;
	enum u32 MT_A = 0x9908B0DFU;
	enum u32 MT_U = 11U;
	enum u32 MT_S = 7U;
	enum u32 MT_B = 0x9D2C5680U;
	enum u32 MT_T = 15U;
	enum u32 MT_C = 0xEFC60000U;
	enum u32 MT_L = 18U;
	fn MT_MAG(u: u32) u32
	{
		if (u == 0) {
			return 0;
		} else {
			return MT_A;
		}
	}

	enum u32 wordSize    = MT_W;
	enum u32 stateSize   = MT_N;
	enum u32 shiftSize   = MT_M;
	enum u32 maskBits    = MT_R;
	enum u32 xorMask     = MT_A;
	enum u32 temperingU  = MT_U;
	enum u32 temperingS  = MT_S;
	enum u32 temperingB  = MT_B;
	enum u32 temperingT  = MT_T;
	enum u32 temperingC  = MT_C;
	enum u32 temperingL  = MT_L;

public:
	/*!
	 * Seed this generator with the given 32 bit value.
	 *
	 * The seed value determines the consequent values retrieved from this generator.
	 * Given two generators with the same seed, and the same generation functions
	 * (`uniformI32`, etc), both generators will generate the same values.  
	 * See @ref mod_watt.io.seed for ways to get a good random seed.
	 * ### Example
	 * ```volt
	 * rnga: MersenneTwisterEngine;
	 * rnga.seed(42);
	 * rngb: MersenneTwisterEngine;
	 * rngb.seed(42);
	 * assert(rnga.front == rngb.front);
	 * rnga.popFront(); rngb.popFront();
	 * assert(rnga.front == rngb.front);
	 * ```
	 */
	fn seed(value: u32 = 5489U/*defaultSeed*/)
	{
		mt[0] = value;
		for (mti = 1; mti < MT_N; ++mti) {
			mt[cast(u32)mti] = cast(u32) (1812433253U * (mt[cast(u32)(mti-1)] ^ (mt[cast(u32)(mti-1)] >>> (MT_W - 2))) + mti);
		}
		inited = true;
		popFront();
	}

	/*!
	 * Advance this generator.
	 *
	 * Changes the value of `front`.
	 * ### Example
	 * ```volt
	 * rng: RandomGenerator;
	 * a := rng.front;
	 * rng.popFront();
	 * assert(a != rng.front);  // Probably true. Maybe not.
	 * ```
	 */
	fn popFront()
	{
		if (!inited) {
			seed();
			return;
		}
		upperMask: u32 = ~((cast(u32) 1u << (MT_SZ * 8 - (MT_W - MT_R))) - 1);
		lowerMask: u32 = (cast(u32) 1u << MT_R) - 1;

		y: u32; // = void;

		if (mti >= MT_N) {
			// Generate N words at one time.
			kk: u32 = 0;
			limit1: const(u32) = MT_N - MT_M;
			for (; kk < limit1; ++kk) {
				y = (mt[cast(u32)kk] & upperMask)|(mt[cast(u32)(kk + 1)] & lowerMask);
				mt[cast(u32)kk] = cast(u32) (mt[cast(u32)(kk+MT_M)]^ (y >>> 1) ^ MT_MAG(cast(u32) y & 0x1U));
			}
			limit2: const(u32) = MT_N - 1;
			for (; kk < limit2; ++kk) {
				y = (mt[cast(u32)kk] & upperMask) | (mt[cast(u32)(kk + 1)] & lowerMask);
				mt[cast(u32)kk] = cast(u32) (mt[cast(u32)(kk + (MT_M - MT_N))] ^ (y >>> 1) ^ MT_MAG(cast(u32) y & 0x1U));
			}
			y = (mt[MT_N - 1] & upperMask)|(mt[0] & lowerMask);
			mt[MT_N - 1] = cast(u32) (mt[MT_M - 1] ^ (y >>> 1) ^ MT_MAG(cast(u32) y & 0x1U));
			mti = 0;
		}

		y = mt[cast(u32)(mti++)];

		// Tempering.
		y ^= (y >>> temperingU);
		y ^= (y << temperingS) & temperingB;
		y ^= (y << temperingT) & temperingC;
		y ^= (y >>> temperingL);

		_y = cast(u32) y;
	}

	/*!
	 * This generator's current value.
	 *
	 * Calling this multiple times
	 * without calling `popFront` will result in the same value.
	 * ### Example
	 * ```volt
	 * rng: RandomGenerator;
	 * assert(rng.front == rng.front);
	 * ```
	 * @Returns The current random value.
	 */
	@property fn front() u32
	{
		if (!inited) {
			seed();
		}
		return _y;
	}

	/*!
	 * Copy this generator.
	 *
	 * Generators are `struct`s, so mutating the value returned by this
	 * function (through `popFront`, etc) will not modify the original generator.  
	 * ### Example
	 * ```volt
	 * rng: RandomGenerator;
	 * rng2 := rng.save();
	 * while (rng2.front == rng.front) rng2.popFront();
	 * assert(rng2.front != rng.front);
	 * ```
	 * @Returns a copy of this generator in its current state.
	 */
	@property fn save() MersenneTwisterEngine
	{
		return this;
	}

	/*!
	 * Is this generator out of values?
	 *
	 * This will never be `true` in any current implementation.
	 */
	@property fn empty() bool
	{
		return false;
	}

	/*!
	 * Generate a `u32` value within a range.
	 *
	 * Note that `lower` is inclusive, `upper` is exclusive.  
	 * @SideEffects The generator is advanced. (`front` will change).
	 * @Returns A value greater than or equal to `lower` but less than `upper`.
	 */
	fn uniformU32(lower: u32, upper: u32) u32
	{
		base: u32 = front;
		popFront();
		return cast(u32)(lower + (upper - lower) * cast(f64)(base - RandomGenerator.min) / (RandomGenerator.max - RandomGenerator.min));
	}

	/*!
	 * Generate an `i32` value within a range.
	 *
	 * Note that `lower` is inclusive, `upper` is exclusive.
	 * @SideEffects The generator is advanced. (`front` will change).
	 * @Returns A value greater than or equal to `lower` but less than `upper`.
	 */
	fn uniformI32(lower: i32, upper: i32) i32
	{
		return cast(i32)uniformU32(cast(u32)lower, cast(u32)upper);
	}

	/*!
	 * Generate a random `string`.
	 *
	 * The `string` will be comprised of digits and letters (upper and lowercase) in equal
	 * distribution.
	 * @Param length The length of the `string` to generate, in characters.
	 * @SideEffects The generator is advanced `length` times.
	 * @Returns A `string` that is `length` characters long.
	 */
	fn randomString(length: size_t) string
	{
		str := new char[](length);
		foreach (i; 0 .. length) {
			c: char;
			switch (uniformI32(0, 3)) {
			case 0:
				c = cast(char)uniformU32('0', '1' + 1U);
				break;
			case 1:
				c = cast(char)uniformU32('a', 'z' + 1U);
				break;
			case 2:
				c = cast(char)uniformU32('A', 'Z' + 1U);
				break;
			default:
				assert(false);
			}
			str[i] = c;
		}
		return cast(immutable(char)[])str[0 .. length];
	}

private:
	mt: u32[624/*MT_N*/];
	mti: u32;// = cast(uint) -1;
	inited: bool;
	_y: u32;// = cast(u32) -1;
}
