// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.sink;


/// The one true sink definition.
alias Sink = scope void delegate(SinkArg);

/// The argument to the one true sink.
alias SinkArg = scope const(char)[];

/// A sink to create long strings.
struct StringSink
{
private:
	char[1024] mStore;
	char[] mArr;
	size_t mLength;

	enum size_t minSize = 16;
	enum size_t maxSize = 2048;

public:
	void sink(SinkArg str)
	{
		auto newSize = str.length + mLength;
		if (mArr.length == 0) {
			mArr = mStore[..];
		}

		if (newSize <= mArr.length) {
			mArr[mLength .. newSize] = str[..];
			mLength = newSize;
			return;
		}

		auto allocSize = mArr.length;
		while (allocSize < newSize) {
			if (allocSize < minSize) {
				allocSize = minSize;
			} else if (allocSize >= maxSize) {
				allocSize += maxSize;
			} else {
				allocSize = allocSize * 2;
			}
		}

		auto n = new char[](newSize + 256);
		n[0 .. mLength] = mArr[0 .. mLength];
		n[mLength .. newSize] = str[..];
		mLength = newSize;
		mArr = n;
	}

	string toString()
	{
		return new string(mArr[0 .. mLength]);
	}

	char[] toChar()
	{
		return new char[](mArr[0 .. mLength]);
	}

	/**
	 * Safely get the backing storage from the sink without coping.
	 */
	void toSink(Sink sink)
	{
		return sink(mArr[0 .. mLength]);
	}

	void reset()
	{
		mArr = null;
		mLength = 0;
	}
}
