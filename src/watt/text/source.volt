// Copyright © 2010-2015, Bernard Helyer.  All rights reserved.
// Copyright © 2012-2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/volt/license.d (BOOST ver. 1.0).
module watt.text.source;

import watt.text.utf : decode;
import watt.text.ascii : isWhite;
import watt.text.format : format;


class Source
{
public:
	/// The location of the current character @p front.
	Location loc;

	/// @see empty.
	alias eof = empty;

private:
	SimpleSource mSrc;

public:
	/**
	 * Sets the source to string and the current location
	 * and validate it as a utf8 source.
	 *
	 * Side-effects:
	 *   Puts all the other fields into known good states.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 */
	this(string s, string filename)
	{
		// mSrc call its own popFront.
		mSrc.source = s;

		// Need to properly setup location.
		loc.filename = filename;
		loc.column = 1;
		loc.line = 1;
	}

	/**
	 * Have we reached EOF, if we have current = dchar.init.
	 */
	final @property dchar empty()
	{
		return mSrc.empty;
	}

	/**
	 * Returns the current utf8 char.
	 *
	 * Side-effects:
	 *   None.
	 */
	final @property dchar front()
	{
		return mSrc.mChar;
	}

	/**
	 * Returns the following utf8 char after front.
	 *
	 * Side-effects:
	 *   None.
	 */
	final @property dchar following()
	{
		return mSrc.following;
	}

	/**
	 * Advance the source one character.
	 *
	 * Side-effects:
	 *   @p eof set to true if we have reached the EOF.
	 *   @p mSrc.mChar is set to the returned character if not at EOF.
	 *   @p mSrc.mNextIndex advanced to the end of the given character.
	 *   @p mSrc.mLastIndex points to the index of the current character.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 */
	void popFront()
	{
		if (mSrc.mChar == '\n') {
			loc.line++;
			loc.column = 0;
		}

		mSrc.popFront();

		loc.column++;
	}

	/**
	 * Advance the source n character.
	 *
	 * Side-effects:
	 *   @p eof set to true if we have reached the EOF.
	 *   @p mSrc.mChar is set to the current character if not at EOF.
	 *   @p mSrc.mNextIndex advanced to the end of the given character.
	 *   @p mSrc.mLastIndex points to the index of the current character.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 */
	void popFrontN(size_t n)
	{
		while (!eof && n != 0) {
			popFront();
			n--;
		}
	}

	/**
	 * Used to skip whitespace in the source file,
	 * as defined by watt.text.ascii.isWhite.
	 *
	 * Side-effects:
	 *   @arg @see popFront
	 */
	final void skipWhitespace()
	{
		while (isWhite(mSrc.mChar) && !eof) {
			popFront();
		}
	}

	/**
	 * Skips till character after next end of line or eof.
	 *
	 * Side-effects:
	 *   @arg @see popFront
	 */
	void skipEndOfLine()
	{
		dchar d;
		do {
			d = front;
			popFront();
		} while (!eof && d == '\n');
	}

	/**
	 * Return the unicode character @p n chars forwards.
	 * @p lookaheadEOF set to true if we reached EOF, otherwise false.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 *
	 * Side-effects:
	 *   None.
	 *
	 * Returns:
	 *   Unicode char at @p n or @p dchar.init at EOF.
	 */
	final dchar lookahead(size_t n, out bool lookaheadEOF)
	{
		return mSrc.lookahead(n, out lookaheadEOF);
	}

	final size_t save()
	{
		return mSrc.mLastIndex;
	}

	final string sliceFrom(size_t mark)
	{
		return mSrc.mSrc[mark .. mSrc.mLastIndex];
	}
}

/**
 * A simple container for iterating over UTF-8 source code.
 *
 * Assumes the given source is valid UTF-8.
 */
struct SimpleSource
{
public:
	/// Source code, assumed to be validated utf8.
	string mSrc;
	/// Pointer into the string for the next character.
	size_t mNextIndex;
	/// The index for mChar
	size_t mLastIndex;
	/// The current unicode character.
	dchar mChar;

	/// @see empty.
	alias eof = empty;

	/// Have we reached EOF, if we have front = dchar.init.
	bool empty;

public:
	@property string source(string src)
	{
		mSrc = src;
		mLastIndex = 0;
		mNextIndex = 0;
		empty = false;
		popFront();
		return src;
	}

	@property string source()
	{
		return mSrc;
	}

	/**
	 * Returns the current utf8 char.
	 *
	 * Side-effects:
	 *   None.
	 */
	@property dchar front()
	{
		return mChar;
	}

	/**
	 * Returns the following utf8 char after front.
	 *
	 * Side-effects:
	 *   None.
	 */
	@property dchar following()
	{
		size_t dummy = mNextIndex;
		return decodeChar(ref dummy);
	}

	/**
	 * Advance the source one character.
	 *
	 * Side-effects:
	 *   @p eof set to true if we have reached the EOF.
	 *   @p mChar is set to the current character if not at EOF.
	 *   @p mNextIndex advanced to the end of the given character.
	 *   @p mLastIndex points to the index of the current character.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 */
	void popFront()
	{
		mLastIndex = mNextIndex;
		mChar = decodeChar(ref mNextIndex);
		if (mChar == dchar.init) {
			empty = true;
			mNextIndex = source.length;
			mLastIndex = source.length;
		}
	}

	/**
	 * Advance the source n character.
	 *
	 * Side-effects:
	 *   @p eof set to true if we have reached the EOF.
	 *   @p mChar is set to the current character if not at EOF.
	 *   @p mNextIndex advanced to the end of the given character.
	 *   @p mLastIndex points to the index of the current character.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 */
	void popFrontN(size_t n)
	{
		while (!empty && n != 0) {
			popFront();
			n--;
		}
	}

	/**
	 * Return the unicode character @p n chars forwards.
	 * @p lookaheadEOF set to true if we reached EOF, otherwise false.
	 *
	 * Throws:
	 *   UtfException if the source is not valid utf8.
	 *
	 * Side-effects:
	 *   None.
	 *
	 * Returns:
	 *   Unicode char at @p n or @p dchar.init at empty.
	 */
	dchar lookahead(size_t n, out bool lookaheadEmpty)
	{
		if (n == 0) {
			lookaheadEmpty = empty;
			return mChar;
		}

		dchar c;
		auto index = mNextIndex;
		for (size_t i; i < n; i++) {
			c = decodeChar(ref index);
			if (c == dchar.init) {
				lookaheadEmpty = true;
				return dchar.init;
			}
		}
		return c;
	}

	/**
	 * Decodes a single utf8 code point at index in the given source.
	 */
	dchar decodeChar(ref size_t index)
	{
		if (index >= source.length) {
			return dchar.init;
		}

		return decode(source, ref index);
	}
}

/**
 * Struct representing a location in a source file.
 *
 * This was pretty much stolen wholesale from Daniel Keep.
 */
struct Location
{
public:
	string filename;
	size_t line;
	size_t column;
	size_t length;

public:
	string toString()
	{
		return format("%s:%s:%s", filename, line, column);
	}

	/**
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * @see difference
	 */
	Location opSub(ref Location begin)
	{
		return difference(ref this, ref begin, ref begin);
	}

	/**
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * On mismatch of filename or if begin is after
	 * end _default is returned.
	 */
	global Location difference(ref Location end, ref Location begin,
	                           ref Location _default)
	{
		if (begin.filename != end.filename ||
		    begin.line > end.line) {
			return _default;
		}

		Location loc;
		loc.filename = begin.filename;
		loc.line = begin.line;
		loc.column = begin.column;

		if (end.line != begin.line) {
			loc.length = size_t.max; // End of line.
		} else {
			assert(begin.column <= end.column);
			loc.length = end.column + end.length - begin.column;
		}

		return loc;
	}

	void spanTo(ref Location end)
	{
		if (line <= end.line && column < end.column) {
			this = end - this;
		}
	}
}
