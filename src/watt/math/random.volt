module watt.math.random;

import watt.io.seed : getHardwareSeedUint;

/// Mersenne Twister engine, adapted from Phobos's std.random.
struct MersenneTwisterEngine
{
public:
	enum uint MT_W = 32U;
	enum uint MT_SZ = 4U;
	enum uint MT_N = 624U;
	enum uint MT_M = 397U;
	enum uint MT_R = 31U;
	enum uint MT_A = 0x9908B0DFU;
	enum uint MT_U = 11U;
	enum uint MT_S = 7U;
	enum uint MT_B = 0x9D2C5680U;
	enum uint MT_T = 15U;
	enum uint MT_C = 0xEFC60000U;
	enum uint MT_L = 18U;
	uint MT_MAG(uint u)
	{
		if (u == 0) {
			return 0;
		} else {
			return MT_A;
		}
	}

	enum uint wordSize    = MT_W;
	enum uint stateSize   = MT_N;
	enum uint shiftSize   = MT_M;
	enum uint maskBits    = MT_R;
	enum uint xorMask     = MT_A;
	enum uint temperingU  = MT_U;
	enum uint temperingS  = MT_S;
	enum uint temperingB  = MT_B;
	enum uint temperingT  = MT_T;
	enum uint temperingC  = MT_C;
	enum uint temperingL  = MT_L;

	/// Smallest generated value.
	enum uint min = 0;
	/// Largest generated value.
	// uint.max >>> (uint.sizeof * 8 - w)
	enum uint max = 0xFFFFFFFFU;//_FFFFFFFFU;
	enum uint defaultSeed = 5489U;

public:
	uint _y;// = cast(uint) -1;

public:
	void seed(uint value = 5489U/*defaultSeed*/)
	{
		mt[0] = value;
		for (mti = 1; mti < MT_N; ++mti) {
			mt[cast(uint)mti] = cast(uint) (1812433253U * (mt[cast(uint)(mti-1)] ^ (mt[cast(uint)(mti-1)] >>> (MT_W - 2))) + mti);
		}
		inited = true;
		popFront();
	}

	/// Advances the generator.
	void popFront()
	{
		if (!inited) {
			seed();
			return;
		}
		uint upperMask = ~((cast(uint) 1u << (MT_SZ * 8 - (MT_W - MT_R))) - 1);
		uint lowerMask = (cast(uint) 1u << MT_R) - 1;

		uint y; // = void;

		if (mti >= MT_N) {
			// Generate N words at one time.
			uint kk = 0;
			const limit1 = MT_N - MT_M;
			for (; kk < limit1; ++kk) {
				y = (mt[cast(uint)kk] & upperMask)|(mt[cast(uint)(kk + 1)] & lowerMask);
				mt[cast(uint)kk] = cast(uint) (mt[cast(uint)(kk+MT_M)]^ (y >>> 1) ^ MT_MAG(cast(uint) y & 0x1U));
			}
			const limit2 = MT_N - 1;
			for (; kk < limit2; ++kk) {
				y = (mt[cast(uint)kk] & upperMask) | (mt[cast(uint)(kk + 1)] & lowerMask);
				mt[cast(uint)kk] = cast(uint) (mt[cast(uint)(kk + (MT_M - MT_N))] ^ (y >>> 1) ^ MT_MAG(cast(uint) y & 0x1U));
			}
			y = (mt[MT_N - 1] & upperMask)|(mt[0] & lowerMask);
			mt[MT_N - 1] = cast(uint) (mt[MT_M - 1] ^ (y >>> 1) ^ MT_MAG(cast(uint) y & 0x1U));
			mti = 0;
		}

		y = mt[cast(uint)(mti++)];

		// Tempering.
		y ^= (y >>> temperingU);
		y ^= (y << temperingS) & temperingB;
		y ^= (y << temperingT) & temperingC;
		y ^= (y >>> temperingL);

		_y = cast(uint) y;
	}

	/// Returns the current random value.
	@property uint front()
	{
		if (!inited) {
			seed();
		}
		return _y;
	}

	@property MersenneTwisterEngine save()
	{
		return this;
	}

	@property bool empty()
	{
		return false;
	}

	uint uniformUint(uint lower, uint upper)
	{
		uint base = front;
		popFront();
		return cast(uint)(lower + (upper - lower) * cast(double)(base - RandomGenerator.min) / (RandomGenerator.max - RandomGenerator.min));
	}

	int uniformInt(int lower, int upper)
	{
		return cast(int)uniformUint(cast(uint)lower, cast(uint)upper);
	}

	string randomString(size_t length)
	{
		auto str = new char[](length);
		foreach (i; 0 .. length) {
			char c;
			switch (uniformInt(0, 3)) {
			case 0:
				c = cast(char)uniformUint(cast(uint)'0', cast(uint)('1')+1);
				break;
			case 1:
				c = cast(char)uniformUint(cast(uint)'a', cast(uint)('z')+1);
				break;
			case 2:
				c = cast(char)uniformUint(cast(uint)'A', cast(uint)('Z')+1);
				break;
			default:
				assert(false);
			}
			str[i] = c;
		}
		return cast(immutable(char)[])str[0 .. length];
	}

private:
	private uint[624/*MT_N*/] mt;
	private uint mti;// = cast(uint) -1;
	private bool inited;
}

alias RandomGenerator = MersenneTwisterEngine;

string randomString(size_t n)
{
	RandomGenerator rng;
	rng.seed(getHardwareSeedUint());
	return rng.randomString(n);
}
