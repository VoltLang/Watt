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
	loc : Location;

	/// @see empty.
	alias eof = empty;

private:
	mSrc : SimpleSource;

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
	this(s : string, filename : string)
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
	final @property fn empty() dchar
	{
		return mSrc.empty;
	}

	/**
	 * Returns the current utf8 char.
	 *
	 * Side-effects:
	 *   None.
	 */
	final @property fn front() dchar
	{
		return mSrc.mChar;
	}

	/**
	 * Returns the following utf8 char after front.
	 *
	 * Side-effects:
	 *   None.
	 */
	final @property fn following() dchar
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
	fn popFront()
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
	fn popFrontN(n : size_t)
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
	final fn skipWhitespace()
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
	fn skipEndOfLine()
	{
		d : dchar;
		do {
			d = front;
			popFront();
		} while (!eof && d != '\n');
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
	final fn lookahead(n : size_t, out lookaheadEOF : bool) dchar
	{
		return mSrc.lookahead(n, out lookaheadEOF);
	}

	final fn save() size_t
	{
		return mSrc.mLastIndex;
	}

	final fn sliceFrom(mark : size_t) string
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
	mSrc : string;
	/// Pointer into the string for the next character.
	mNextIndex : size_t;
	/// The index for mChar
	mLastIndex : size_t;
	/// The current unicode character.
	mChar : dchar;

	/// @see empty.
	alias eof = empty;

	/// Have we reached EOF, if we have front = dchar.init.
	empty : bool;

public:
	@property fn source(src : string) string
	{
		mSrc = src;
		mLastIndex = 0;
		mNextIndex = 0;
		empty = false;
		popFront();
		return src;
	}

	@property fn source() string
	{
		return mSrc;
	}

	/**
	 * Returns the current utf8 char.
	 *
	 * Side-effects:
	 *   None.
	 */
	@property fn front() dchar
	{
		return mChar;
	}

	/**
	 * Returns the following utf8 char after front.
	 *
	 * Side-effects:
	 *   None.
	 */
	@property fn following() dchar
	{
		dummy : size_t = mNextIndex;
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
	fn popFront()
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
	fn popFrontN(n : size_t)
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
	fn lookahead(n : size_t, out lookaheadEmpty : bool) dchar
	{
		if (n == 0) {
			lookaheadEmpty = empty;
			return mChar;
		}

		c : dchar;
		index := mNextIndex;
		for (i : size_t; i < n; i++) {
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
	fn decodeChar(ref index : size_t) dchar
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
	filename : string;
	line : size_t;
	column : size_t;
	length : size_t;

public:
	fn toString() string
	{
		return format("%s:%s:%s", filename, line, column);
	}

	/**
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * @see difference
	 */
	fn opSub(ref begin : Location) Location
	{
		return difference(ref this, ref begin, ref begin);
	}

	/**
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * On mismatch of filename or if begin is after
	 * end _default is returned.
	 */
	global fn difference(ref end : Location, ref begin : Location,
	                     ref _default : Location) Location
	{
		if (begin.filename != end.filename ||
		    begin.line > end.line) {
			return _default;
		}

		loc : Location;
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

	fn spanTo(ref end : Location)
	{
		if (line <= end.line && column < end.column) {
			this = end - this;
		}
	}
}
