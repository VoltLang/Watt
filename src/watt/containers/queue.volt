// Copyright 2018, Jakob Bornecrantz.
// Copyright 2018, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
//! A templated queue data structure.
module watt.containers.queue;

import core.exception;

/*!
 * Reasonably efficient queue implementation.  
 * Only pass this struct by reference, do not pass it by value.
 * @Param T The type enqueued in this Queue.
 */
struct Queue!(T)
{
public:
	enum size_t MaxSize = 2048;  //!< The maximum size chunk memory is allocated in, in bytes.

	//! How many elements are contained in this queue?
	@property fn length() size_t
	{
		return mLength;
	}

private:
	mStore:   T[32];
	mArr:     T[];
	mLength:  size_t;
	mInsert:    size_t;

public:
	/*!
	 * Add a value to become the back of the queue.
	 */
	fn enqueue(val: T)
	{
		newSize := mLength + 1;
		if (mArr.length == 0) {
			mArr = mStore[0 .. $];
			mInsert = mArr.length - 1;
		}

		if (newSize <= mArr.length) {
			mLength++;
			mArr[mInsert--] = val;
			return;
		}

		allocSize := mArr.length;
		while (allocSize < newSize) {
			if (allocSize >= MaxSize) {
				allocSize += MaxSize;
			} else {
				allocSize = allocSize * 2;
			}
		}

		n := new T[](allocSize);
		n[$-mLength .. $] = mArr[0 .. mLength];
		mInsert += (n.length - mArr.length);
		mLength++;
		n[mInsert--] = val;
		mArr = n;
	}

	/*!
	 * Remove the front element of the queue and return it.
	 */
	fn dequeue() T
	{
		assert(mArr.length > 0, "dequeue()ed an empty queue");
		T val = mArr[mInsert+mLength];
		mLength--;
		return val;
	}

	/*!
	 * Return the front element of the queue without removing it.
	 */
	fn peek() T
	{
		assert(mArr.length > 0, "peek()ed an empty queue");
		return mArr[mInsert+mLength];
	}

	/*!
	 * Reset the queue to an empty state.
	 */
	fn clear()
	{
		mArr = null;
		mLength = 0;
		mInsert = 0;
	}

	/*!
	 * Unsafely get a reference to the underlying array.  
	 * Mutating this array may (or may not) impact the queue data structure.
	 * Taking a copy and mutating *that* is recommended.
	 */
	fn borrowUnsafe() T[]
	{
		return mArr[mInsert+1 .. mInsert+mLength+1];
	}
}