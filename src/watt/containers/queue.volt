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
	mRear:    size_t;

public:
	/*!
	 * Add a value to become the back of the queue.
	 */
	fn enqueue(val: T)
	{
		if (mArr.length == 0) {
			mArr = mStore[0 .. $];
		}

		if (mLength + 1 > mArr.length) {
			resize();
		}

		mArr[(mRear+mLength) % $] = val;
		mLength++;
		return;
	}

	/*!
	 * Remove the front element of the queue and return it.
	 */
	fn dequeue() T
	{
		assert(mArr.length > 0, "dequeue()ed an empty queue");
		T val = mArr[mRear];
		mRear = (mRear + 1) % mArr.length;
		mLength--;
		return val;
	}

	/*!
	 * Return the front element of the queue without removing it.
	 */
	fn peek() T
	{
		assert(mArr.length > 0, "peek()ed an empty queue");
		return mArr[mRear];
	}

	/*!
	 * Reset the queue to an empty state.
	 */
	fn clear()
	{
		mArr = null;
		mLength = 0;
		mRear = 0;
	}

private:
	fn resize()
	{
		allocSize := mArr.length;
		while (allocSize < mLength + 1) {
			if (allocSize >= MaxSize) {
				allocSize += MaxSize;
			} else {
				allocSize = allocSize * 2;
			}
		}
		n := new T[](allocSize);
		for (k: size_t = 0; k < mLength; ++k) {
			n[k] = mArr[(mRear+k) % $];
		}
		mArr = n;
		mRear = 0;
	}
}