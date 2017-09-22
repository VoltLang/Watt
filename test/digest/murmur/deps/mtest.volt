module mtest;

import watt.digest.murmur;
import core.rt.format;

bool checkResult(input: string, result: string)
{
	_out := getHashString(input);
	return _out == result;
}

fn getHashString(input: string) string
{
	hash := hashMurmur_32(cast(void[])input);
	_outstr: string;
	fn sink(a: scope const(char)[]) {
		_outstr ~= new string(a);
	}
	vrt_format_hex(sink, hash, 8);
	return _outstr;
}
