// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.seed;

import core.windows.windows;

version (Windows) {
	alias HCRYPTPROV = size_t*;
	extern (Windows) BOOL CryptAcquireContextA(HCRYPTPROV*, LPCSTR, LPCSTR, DWORD, DWORD);
	extern (Windows) BOOL CryptReleaseContext(HCRYPTPROV, DWORD);
	extern (Windows) BOOL CryptGenRandom(HCRYPTPROV, DWORD, ubyte*);
	enum PROV_RSA_FULL = 1;
	enum CRYPT_NEWKEYSET = 0x00000008;

	uint getHardwareSeedUint()
	{
		auto buf = new uint[](1);
		HCRYPTPROV hcpov;
		if (!CryptAcquireContextA(&hcpov, null, null, PROV_RSA_FULL, 0)) {
			throw new Exception("Can't get CryptoAPI provider.");
		}
		if (!CryptGenRandom(hcpov, 4, cast(ubyte*)buf.ptr)) {
			throw new Exception("Can't get random bytes from CryptoAPI.");
		}
		CryptReleaseContext(hcpov, 0);
		return buf[0];
	}
} else version (OSX || Linux) {
	private import watt.io.streams : InputFileStream;

	uint getHardwareSeedUint()
	{
		auto ifs = new InputFileStream("/dev/urandom");
		uint ret;
		for (uint i; i < 32; i += 8) {
			ret |= cast(uint)((ifs.get() & 0xff) << i);
		}
		ifs.close();

		return ret;
	}
} else version (Emscripten) {
	uint getHardwareSeedUint()
	{
		assert(false);
	}
} else {
	static assert(false);
}
