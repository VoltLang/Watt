// Copyright 2015-2018, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
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


//! A `Sink` is a delegate that accepts strings and concatenates them efficiently.
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

	@property fn length() size_t
	{
		return mLength;
	}
}

struct StringsSink = mixin SinkStruct!string;

struct SinkStruct!(T)
{
public:
	//! The one true sink definition.
	alias Sink = dg(SinkArg);

	//! The argument to the one true sink.
	alias SinkArg = scope T[];

	enum size_t MinSize = 16;
	enum size_t MaxSize = 2048;

	@property size_t length()
	{
		return mLength;
	}


private:
	mStore: T[32];
	mArr: T[];
	mLength: size_t;


public:
	fn sink(type: T)
	{
		auto newSize = mLength + 1;
		if (mArr.length == 0) {
			mArr = mStore[0 .. $];
		}

		if (newSize <= mArr.length) {
			mArr[mLength++] = type;
			return;
		}

		auto allocSize = mArr.length;
		while (allocSize < newSize) {
			if (allocSize >= MaxSize) {
				allocSize += MaxSize;
			} else {
				allocSize = allocSize * 2;
			}
		}

		auto n = new T[](allocSize);
		n[0 .. mLength] = mArr[0 .. mLength];
		n[mLength++] = type;
		mArr = n;
	}

	fn append(arr: scope T[])
	{
		foreach (e; arr) {
			sink(e);
		}
	}

	fn append(s: SinkStruct)
	{
		fn func(sa: SinkArg) {
			foreach (e; sa) {
				sink(e);
			}
		}

		s.toSink(func);
	}

	fn popLast() T
	{
		if (mLength > 0) {
			return mArr[--mLength];
		}
		return T.default;
	}

	fn getLast() T
	{
		return mArr[mLength - 1];
	}

	fn get(i: size_t) T
	{
		return mArr[i];
	}

	fn set(i: size_t, n: T )
	{
		mArr[i] = n;
	}

	fn setLast(i: T)
	{
		mArr[mLength - 1] = i;
	}

	/*!
	 * Safely get the backing storage from the sink without copying.
	 */
	fn toSink(sink: Sink)
	{
		return sink(mArr[0 .. mLength]);
	}

	/*!
	 * Use this as sparingly as possible. Use toSink where possible.
	 */
	fn toArray() T[]
	{
		auto _out = new T[](mLength);
		_out[] = mArr[0 .. mLength];
		return _out;
	}

	/*!
	 * Unsafely get a reference to the array.
	 */
	fn borrowUnsafe() T[]
	{
		return mArr[0 .. mLength];
	}

	fn reset()
	{
		mLength = 0;
	}
}
