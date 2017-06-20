// Copyright © 2015-2016, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! A psuedo-random number generator.
module watt.math.random;


//! Default RandomGenerator.
alias RandomGenerator = MersenneTwisterEngine;

//! Mersenne Twister engine, adapted from Phobos's std.random.
struct MersenneTwisterEngine
{
public:
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

	//! Smallest generated value.
	enum u32 min = 0;
	//! Largest generated value.
	// u32.max >>> (uint.sizeof * 8 - w)
	enum u32 max = 0xFFFFFFFFU;//_FFFFFFFFU;
	enum u32 defaultSeed = 5489U;

public:
	_y: u32;// = cast(u32) -1;

public:
	/*!
	 * Seed this generator with the given 32 bit value.
	 * See @p watt.io.seed for ways to get a good random seed.
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

	//! Advances the generator.
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

	//! Returns the current random value.
	@property fn front() u32
	{
		if (!inited) {
			seed();
		}
		return _y;
	}

	//! Return a copy of this generator in its current state.
	@property fn save() MersenneTwisterEngine
	{
		return this;
	}

	//! Is this generator out of numbers? Always false.
	@property fn empty() bool
	{
		return false;
	}

	/*!
	 * Generate an integer.
	 * @return A value >= to @p lower and < @p upper.
	 * @{
	 */
	fn uniformU32(lower: u32, upper: u32) u32
	{
		base: u32 = front;
		popFront();
		return cast(u32)(lower + (upper - lower) * cast(f64)(base - RandomGenerator.min) / (RandomGenerator.max - RandomGenerator.min));
	}

	fn uniformI32(lower: i32, upper: i32) i32
	{
		return cast(i32)uniformU32(cast(u32)lower, cast(u32)upper);
	}
	//! @}

	//! Generate a random string @p length long.
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
	private mt: u32[624/*MT_N*/];
	private mti: u32;// = cast(uint) -1;
	private inited: bool;
}
