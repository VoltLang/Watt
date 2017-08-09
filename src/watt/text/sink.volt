// Copyright © 2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Construct long strings of text efficiently.
 *
 * The concatenation operator (`~` and `~=`) while convenient, is
 * not efficient, as it likely causes an allocation each and every
 * time it occurs.
 *
 * The `StringSink` allocates memory in large chunks, reducing the
 * overall amount of allocation that takes place. Using this if
 * you are going to be building a lot of strings is recommended.
 */
module watt.text.sink;

static import core.rt.format;


//! A `Sink` is a type that accepts strings and concatenates them efficiently.
alias Sink = core.rt.format.Sink;

//! A `SinkArg` is shorthand for the string argument to a `Sink`.
alias SinkArg = core.rt.format.SinkArg;

/*!
 * Helps construct long strings efficiently.
 *
 * ### Example
 * ```volt
 * ss: StringSink;
 * ss.sink("Hello, ");
 * ss.sink("world.");
 * assert(ss.toString() == "Hello, world.");
 * ss.reset();
 * assert(ss.toString() == "");
 * ```
 */
struct StringSink
{
private:
	mStore: char[1024];
	mArr: char[];
	mLength: size_t;

	enum size_t minSize = 16;
	enum size_t maxSize = 2048;

public:
	//! Add @p str to this sink.
	fn sink(str: SinkArg) void
	{
		newSize := str.length + mLength;
		if (mArr.length == 0) {
			mArr = mStore[..];
		}

		if (newSize <= mArr.length) {
			mArr[mLength .. newSize] = str[..];
			mLength = newSize;
			return;
		}

		allocSize := mArr.length;
		while (allocSize < newSize) {
			if (allocSize < minSize) {
				allocSize = minSize;
			} else if (allocSize >= maxSize) {
				allocSize += maxSize;
			} else {
				allocSize = allocSize * 2;
			}
		}

		n := new char[](newSize + 256);
		n[0 .. mLength] = mArr[0 .. mLength];
		n[mLength .. newSize] = str[..];
		mLength = newSize;
		mArr = n;
	}

	//! Get the contents of this sink as a string.
	fn toString() string
	{
		return new string(mArr[0 .. mLength]);
	}

	//! Get the contents of this sink as a mutable array of characters.
	fn toChar() char[]
	{
		return new char[](mArr[0 .. mLength]);
	}

	/*!
	 * Safely get the backing storage from the sink without copying.
	 */
	fn toSink(sink: Sink) void
	{
		return sink(mArr[0 .. mLength]);
	}

	//! Clear this sink.
	fn reset() void
	{
		mArr = null;
		mLength = 0;
	}
}
