// Copyright © 2016, Jakob Bornecrantz.  All rights reserved.
// Copyright © 2010-2012, Jonathan M Davis.  All rights reserved.
// Copyright © 2010-2012, Kato Shoichi.  All rights reserved.
// See copyright notice in src/volt/license.d (BOOST ver. 1.0).
module vrt.time;


global long ticksPerSecond;

global this()
{
	version (Windows) {
		ticksPerSecond = windowsTicksPerSecond();
	} else version (OSX) {
		ticksPerSecond = machTicksPerSecond();
	} else version (Posix) {
		ticksPerSecond = posixTicksPerSecond(CLOCK_MONOTONIC);
	} else version (Emscripten) {
		ticksPerSecond = 1_000_000_000L;
	} else {
		static assert(false);
	}
}

extern(C) {
	void exit(int);
}

version (Windows) {

	extern (Windows) {
		int QueryPerformanceFrequency(long*);
		int QueryPerformanceCounter(long*);
	}

	long windowsTicksPerSecond()
	{
		long ticks;
		if (QueryPerformanceFrequency(&ticks) == 0) {
			exit(-1);
		}
		return ticks;
	}

	long ticks()
	{
		long ticks;
		if (QueryPerformanceCounter(&ticks) == 0) {
			exit(-1);
		}
		return ticks;
	}

} else version (OSX) {

	extern(C) {
		struct mach_timebase_info_data_t
		{
			uint numer;
			uint denom;
		}

		alias mach_timebase_info_t = mach_timebase_info_data_t*;

		int mach_timebase_info(mach_timebase_info_t);

		ulong mach_absolute_time();
	}

	/*
	 * Grabbed verbatim from druntume, good thing its BOOST v1.0 as well.
	 */
	long machTicksPerSecond()
	{
		mach_timebase_info_data_t info;
		if(mach_timebase_info(&info) != 0) {
			exit(-1);
		}

		long scaledDenom = 1_000_000_000L * info.denom;
		if (scaledDenom % info.numer != 0) {
			exit(-1);
		}

		return scaledDenom / info.numer;
	}

	long ticks()
	{
		return cast(long)mach_absolute_time();
	}

} else version (Posix) {

	import core.posix.time;

	long posixTicksPerSecond(int clock)
	{
		timespec ts;
		if (clock_getres(clock, &ts) !=  0) {
			exit(-1);
		}
		return ts.tv_nsec >= 1000 ?
			1_000_000_000L :
			1_000_000_000L / ts.tv_nsec;
	}

	long posixTicks(int clock)
	{
		timespec ts;
		if (clock_gettime(clock, &ts) != 0) {
			exit(-1);
		}
		return convClockFreq(
			ts.tv_sec * 1_000_000_000L + ts.tv_nsec,
			1_000_000_000L, ticksPerSecond);
	}

	long ticks()
	{
		return posixTicks(CLOCK_MONOTONIC);
	}
}

/*
 * Grabbed verbatim from druntime, good thing its BOOST v1.0 as well.
 */
@safe pure nothrow
long convClockFreq(long ticks, long srcTicksPerSecond, long dstTicksPerSecond)
{
	// This would be more straightforward with floating point arithmetic,
	// but we avoid it here in order to avoid the rounding errors that that
	// introduces. Also, by splitting out the units in this way, we're able
	// to deal with much larger values before running into problems with
	// integer overflow.
	return ticks / srcTicksPerSecond * dstTicksPerSecond +
		ticks % srcTicksPerSecond * dstTicksPerSecond / srcTicksPerSecond;
}
