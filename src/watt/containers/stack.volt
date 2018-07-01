// Copyright 2018, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
//! A templated stack data structure.
module watt.containers.stack;

import core.exception;

/*!
 * Reasonably efficient stack implementation.  
 * Only pass this struct by reference, do not pass it by value.
 * @Param T The type contained in this Stack.
 */
struct Stack!(T)
{
public:
	enum size_t MaxSize = 2048;  //!< The maximum size chunk memory is allocated in, in bytes.

	//! How many elements are contained in this stack?
	@property fn length() size_t
	{
		return mLength;
	}

private:
	mStore:   T[32];
	mArr:     T[];
	mLength:  size_t;

public:
	/*!
	 * Add a value to become the top of the stack.
	 */
	fn push(val: T)
	{
		newSize := mLength + 1;
		if (mArr.length == 0) {
			mArr = mStore[0 .. $];
		}

		if (newSize <= mArr.length) {
			mArr[mLength++] = val;
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
		n[0 .. mLength] = mArr[0 .. mLength];
		n[mLength++] = val;
		mArr = n;
	}

	/*!
	 * Remove the top element of the stack and return it.
	 */
	fn pop() T
	{
		if (mArr.length == 0) {
			throw new Exception("pop()ed an empty stack");
		}
		T val = mArr[mLength-1];
		mLength--;
		return val;
	}

	/*!
	 * Return the top element of the stack without removing it.
	 */
	fn peek() T
	{
		if (mArr.length == 0) {
			throw new Exception("peek()ed an empty stack");
		}
		return mArr[mLength-1];
	}

	/*!
	 * Reset the stack to an empty state.
	 */
	fn clear()
	{
		mArr = null;
		mLength = 0;
	}

	/*!
	 * Unsafely get a reference to the underlying array.  
	 * Mutating this array may (or may not) impact the stack data structure.
	 * Taking a copy and mutating *that* is recommended.
	 */
	fn borrowUnsafe() T[]
	{
		return mArr[0 .. mLength];
	}
}