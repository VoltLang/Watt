// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.file;

import core.stdc.stdio;
import watt.text.format;

/**
 * Read the contents of the file pointed to by filename into a string with no verification.
 */
void[] read(string filename)
{
	auto cstr = filename ~ "\0";
	auto fp = fopen(cstr.ptr, "rb");
	if (fp is null) {
		throw new Exception(format("Couldn't open file '%s' for reading.", filename));
	}

	if (fseek(fp, 0, SEEK_END) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	size_t size = cast(size_t) ftell(fp);
	if (size == cast(size_t) -1) {
		throw new Exception("ftell failure.");
	}

	if (fseek(fp, 0, SEEK_SET) != 0) {
		fclose(fp);
		throw new Exception("fseek failure.");
	}

	auto buf = new char[](size);
	size_t bytesRead = fread(buf.ptr, 1, size, fp);
	if (bytesRead != size) {
		throw new Exception("read failure.");
	}

	fclose(fp);

	return cast(void[]) buf;
}

