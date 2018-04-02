// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Get a random 32 bit number from the Operating System.
 *
 * This number is ideal for seeding random number generators,
 * such as Watt's very own @ref watt.math.random.
 */
module watt.io.seed;

import core.exception;
import core.c.windows.windows;

/*!
 * Get a random unsigned 32 bit integer.
 *
 * This is sourced from the hardware or a strong source provided
 * by the Operating System, where possible. Intended to be used for
 * random number generator seed values.
 *
 * ### Example
 * ```volt
 * gen: RandomGenerator;
 * gen.seed(getHardwareSeedU32());
 * ```
 */
fn getHardwareSeedU32() u32
{
	return getHardwareSeedU32Impl();
}

private:

version (Windows) {
	alias HCRYPTPROV = size_t*;
	extern (Windows) fn CryptAcquireContextA(HCRYPTPROV*, LPCSTR, LPCSTR, DWORD, DWORD) BOOL;
	extern (Windows) fn CryptReleaseContext(HCRYPTPROV, DWORD) BOOL;
	extern (Windows) fn CryptGenRandom(HCRYPTPROV, DWORD, u8*) BOOL;
	enum PROV_RSA_FULL = 1;
	enum CRYPT_NEWKEYSET     = 0x00000008;
	enum CRYPT_VERIFYCONTEXT = 0xF0000000;

	fn getHardwareSeedU32Impl() u32
	{
		buf := new u32[](1);
		hcpov: HCRYPTPROV;
		if (!CryptAcquireContextA(&hcpov, null, null, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) {
			throw new Exception("Can't get CryptoAPI provider.");
		}
		if (!CryptGenRandom(hcpov, 4, cast(u8*)buf.ptr)) {
			throw new Exception("Can't get random bytes from CryptoAPI.");
		}
		CryptReleaseContext(hcpov, 0);
		return buf[0];
	}
} else version (OSX || Linux) {
	private import watt.io.streams: InputFileStream;

	fn getHardwareSeedU32Impl() u32
	{
		ifs := new InputFileStream("/dev/urandom");
		ret: u32;
		for (i: u32; i < 32; i += 8) {
			ret |= cast(u32)((ifs.get() & 0xff) << i);
		}
		ifs.close();

		return ret;
	}
} else {
	static assert(false);
}
