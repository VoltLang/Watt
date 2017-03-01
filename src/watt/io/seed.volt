// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.seed;

import core.exception;
import core.c.windows.windows;

version (Windows) {
	alias HCRYPTPROV = size_t*;
	extern (Windows) fn CryptAcquireContextA(HCRYPTPROV*, LPCSTR, LPCSTR, DWORD, DWORD) BOOL;
	extern (Windows) fn CryptReleaseContext(HCRYPTPROV, DWORD) BOOL;
	extern (Windows) fn CryptGenRandom(HCRYPTPROV, DWORD, u8*) BOOL;
	enum PROV_RSA_FULL = 1;
	enum CRYPT_NEWKEYSET = 0x00000008;

	fn getHardwareSeedU32() u32
	{
		buf := new u32[](1);
		hcpov: HCRYPTPROV;
		if (!CryptAcquireContextA(&hcpov, null, null, PROV_RSA_FULL, 0)) {
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

	fn getHardwareSeedU32() u32
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
