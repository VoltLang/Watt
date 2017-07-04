// Copyright © 2010-2015, Bernard Helyer.  All rights reserved.
// Copyright © 2012-2015, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/volt/license.d (BOOST ver. 1.0).
//! A class for dealing with a file from the perspective of a compiler.
module watt.text.source;

import watt.text.utf: decode;
import watt.text.ascii: isWhite;
import watt.text.format: format;


/*!
 * A container for iterating over UTF-8 source code.
 *
 * Assumes the given source is valid UTF-8.
 */
class Source
{
public:
	//! The location of the current character @p front.
	loc: Location;
	//! @see empty.
	alias eof = empty;


private:
	//! Base source.
	mSrc: SimpleSource;


public:
	/*!
	 * Sets the source to string and the current location
	 * and validate it as a utf8 source.
	 *
	 * @SideEffects Puts all the other fields into known good states.
	 *
	 * @Throws UtfException if the source is not valid utf8.
	 */
	this(s: string, filename: string)
	{
		// mSrc call its own popFront.
		mSrc.source = s;

		// Need to properly setup location.
		loc.filename = filename;
		loc.column = 1;
		loc.line = 1;
	}

	/*!
	 * Have we reached EOF, if we have current = dchar.init.
	 */
	final @property fn empty() dchar
	{
		return mSrc.empty;
	}

	/*!
	 * Returns the current utf8 char.
	 *
	 * @SideEffects None.
	 */
	final @property fn front() dchar
	{
		return mSrc.mChar;
	}

	/*!
	 * Returns the following utf8 char after front.
	 *
	 * @SideEffects None.
	 */
	final @property fn following() dchar
	{
		return mSrc.following;
	}

	/*!
	 * Advance the source one character.
	 *
	 * @SideEffect @p eof set to true if we have reached the EOF.
	 * @SideEffect @p mSrc.mChar is set to the returned character if not at EOF.
	 * @SideEffect @p mSrc.mNextIndex advanced to the end of the given character.
	 * @SideEffect @p mSrc.mLastIndex points to the index of the current character.
	 *
	 * @Throws UtfException if the source is not valid utf8.
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

	/*!
	 * Advance the source n character.
	 *
	 * @SideEffect @p eof set to true if we have reached the EOF.
	 * @SideEffect @p mSrc.mChar is set to the current character if not at EOF.
	 * @SideEffect @p mSrc.mNextIndex advanced to the end of the given character.
	 * @SideEffect @p mSrc.mLastIndex points to the index of the current character.
	 *
	 * @Throws UtfException if the source is not valid utf8.
	 */
	fn popFrontN(n: size_t)
	{
		while (!eof && n != 0) {
			popFront();
			n--;
		}
	}

	/*!
	 * Used to skip whitespace in the source file,
	 * as defined by watt.text.ascii.isWhite.
	 *
	 * @SideEffects See @ref popFront.
	 */
	final fn skipWhitespace()
	{
		while (isWhite(mSrc.mChar) && !eof) {
			popFront();
		}
	}

	/*!
	 * Skips till character after next end of line or eof.
	 *
	 * @SideEffects See @ref popFront.
	 */
	fn skipEndOfLine()
	{
		d: dchar;
		do {
			d = front;
			popFront();
		} while (!eof && d != '\n');
	}

	/*!
	 * Return the unicode character @p n chars forwards.
	 * @p lookaheadEOF set to true if we reached EOF, otherwise false.
	 *
	 * @Throws UtfException if the source is not valid utf8.
	 *
	 * @SideEffects None.
	 *
	 * @Returns Unicode char at @p n or @p dchar.init at EOF.
	 */
	final fn lookahead(n: size_t, out lookaheadEOF: bool) dchar
	{
		return mSrc.lookahead(n, out lookaheadEOF);
	}

	/*!
	 * Return the index of the current character.
	 *
	 * @SideEffects None.
	 */
	final fn save() size_t
	{
		return mSrc.save();
	}

	/*!
	 * Slices the source from the given mark to (but not including) the
	 * current character. Use @p save for indicies.
	 *
	 * @SideEffects None.
	 */
	final fn sliceFrom(mark: size_t) string
	{
		return mSrc.sliceFrom(mark);
	}
}

/*!
 * A simple container for iterating over UTF-8 source code.
 *
 * Assumes the given source is valid UTF-8.
 */
struct SimpleSource
{
private:
	//! Source code, assumed to be validated utf8.
	mSrc: string;
	//! Pointer into the string for the next character.
	mNextIndex: size_t;
	//! The index for mChar.
	mLastIndex: size_t;
	//! The current unicode character.
	mChar: dchar;


public:
	//! @see empty.
	alias eof = empty;

	//! Have we reached EOF, if we have front = dchar.init.
	empty: bool;


public:
	//! Setup this simple source and return the full source.
	@property fn source(src: string) string
	{
		mSrc = src;
		mLastIndex = 0;
		mNextIndex = 0;
		empty = false;
		popFront();
		return src;
	}

	//! Return the full source.
	@property fn source() string
	{
		return mSrc;
	}

	/*!
	 * Returns the current utf8 char.
	 *
	 * @SideEffects None.
	 */
	@property fn front() dchar
	{
		return mChar;
	}

	/*!
	 * Returns the following utf8 char after front.
	 *
	 * @SideEffects None.
	 */
	@property fn following() dchar
	{
		dummy: size_t = mNextIndex;
		return decodeChar(ref dummy);
	}

	/*!
	 * Advance the source one character.
	 *
	 * @SideEffect @p eof set to true if we have reached the EOF.
	 * @SideEffect @p mChar is set to the current character if not at EOF.
	 * @SideEffect @p mNextIndex advanced to the end of the given character.
	 * @SideEffect @p mLastIndex points to the index of the current character.
	 *
	 * @Throws UtfException if the source is not valid utf8.
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

	/*!
	 * Advance the source n character.
	 *
	 * @SideEffect @p eof set to true if we have reached the EOF.
	 * @SideEffect @p mChar is set to the current character if not at EOF.
	 * @SideEffect @p mNextIndex advanced to the end of the given character.
	 * @SideEffect @p mLastIndex points to the index of the current character.
	 *
	 * @Throws UtfException if the source is not valid utf8.
	 */
	fn popFrontN(n: size_t)
	{
		while (!empty && n != 0) {
			popFront();
			n--;
		}
	}

	/*!
	 * Return the unicode character @p n chars forwards.
	 * @p lookaheadEOF set to true if we reached EOF, otherwise false.
	 *
	 * @Returns Unicode char at @p n or @p dchar.init at empty.
	 *
	 * @Throws UtfException if the source is not valid utf8.
	 *
	 * @SideEffects None.
	 */
	fn lookahead(n: size_t, out lookaheadEmpty: bool) dchar
	{
		if (n == 0) {
			lookaheadEmpty = empty;
			return mChar;
		}

		c: dchar;
		index := mNextIndex;
		for (i: size_t; i < n; i++) {
			c = decodeChar(ref index);
			if (c == dchar.init) {
				lookaheadEmpty = true;
				return dchar.init;
			}
		}
		return c;
	}

	/*!
	 * Used to skip whitespace in the source file,
	 * as defined by watt.text.ascii.isWhite.
	 *
	 * @SideEffects See @ref popFront.
	 */
	fn skipWhitespace()
	{
		while (!empty && isWhite(front)) {
			popFront();
		}
	}

	/*!
	 * Return the index of the current character.
	 *
	 * @SideEffects None.
	 */
	fn save() size_t
	{
		return mLastIndex;
	}

	/*!
	 * Slices the source from the given mark to (but not including) the
	 * current character. Use @p save for indicies.
	 *
	 * @SideEffects None.
	 */
	fn sliceFrom(mark: size_t) string
	{
		if (mark < mLastIndex) {
			return mSrc[mark .. mLastIndex];
		} else {
			return null;
		}
	}

	/*!
	 * Decodes a single utf8 code point at index in the given source.
	 *
	 * @SideEffects None.
	 *
	 * @Returns Unicode char at @p index or @p dchar.init if out of bound.
	 */
	fn decodeChar(ref index: size_t) dchar
	{
		if (index >= source.length) {
			return dchar.init;
		}

		return decode(source, ref index);
	}
}

/*!
 * Struct representing a location in a source file.
 *
 * This was pretty much stolen wholesale from Daniel Keep.
 */
struct Location
{
public:
	//! The file from pointed to this locatiom.
	filename: string;
	//! Line number starting at 1.
	line: size_t;
	//! Column starting at 1.
	column: size_t;
	//! Length in characers.
	length: size_t;


public:
	//! Format into a @p location string.
	fn toString() string
	{
		return format("%s:%s:%s", filename, line, column);
	}

	/*!
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * @see difference
	 */
	fn opSub(ref begin: Location) Location
	{
		return difference(ref this, ref begin, ref begin);
	}

	/*!
	 * Difference between two locations.
	 * end - begin == begin ... end
	 * On mismatch of filename or if begin is after
	 * end _default is returned.
	 */
	global fn difference(ref end: Location, ref begin: Location,
	                     ref _default: Location) Location
	{
		if (begin.filename != end.filename ||
		    begin.line > end.line) {
			return _default;
		}

		loc: Location;
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

	//! See @ref difference.
	fn spanTo(ref end: Location)
	{
		if (line <= end.line && column < end.column) {
			this = end - this;
		}
	}
}
