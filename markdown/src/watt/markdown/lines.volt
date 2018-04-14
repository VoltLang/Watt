// Copyright 2016-2017, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
//! Split a file into line objects..
module watt.markdown.lines;

import watt.io;
import watt.algorithm;
import watt.markdown.util;
import watt.text.string : wattSplit = splitLines, wattStrip = strip,
	wattReplace = replace;
import watt.text.ascii;

/*!
 * Represents a line of input.
 *
 * CommonMark handles tabs as tabs with a tab stop of 4 set.
 * The tab stop is considered with regards to the whole line,
 * even parts that a given parsing function won't see.
 *
 * Consider the following, a >, two tabs, and the string "content".
 *
 *      >		content
 *
 * The rules for blockquotes state that a block quote is a '>' an
 * optional space, and the rest of the line is the content.
 *
 * The rules for indented code blocks state that an indented codeblock
 * is four spaces of indentation, and then the content of the codeblock.
 * If the rule was "tabs are expanded to four spaces", the above would be
 * trivial.
 *
 *     ><tab><tab>content
 *
 * Becomes (where '.' is space)
 *
 *     >........content
 *
 * The '> ' is consumed when the blockquote is parsed, and then
 *
 *     .......content
 *
 * Is parsed as a code block, with the result being
 *
 *     ...content
 *
 * A codeblock with content indented by three spaces.
 * But that is not how CommonMark handles tabs.
 *
 * Tabs are considered to be expanded to spaces where they have to be
 * (when you're removing leading whitespace, as above, for example), but
 * as tab stops, so the text rounds to 4, considering the <entire line>. So,
 * (given that | is invisible and represents groups of four characters):
 *
 *     ><tab><tab>c|onte|nt
 * 
 * Becomes (where 
 *
 *     >...|<tab>con|tent
 *
 * The '> ' is removed, as before. (where the text in parens has been removed,
 * but we need to consider it so as to not break tab stops).
 *
 *     (>.)..|<tab>con|tent
 *
 * Then the codeblock parser needs to remove four spaces of indentation, and as
 * we only have two spaces on front, we need to expand the tab again.
 *
 *     (>.)..|....|cont|ent
 *
 * And remove four spaces.
 *
 *     (>...)|(..)..|cont|ent
 *
 * And that's how '>		content' becomes '  content' in a quoted codeblock. Simple!
 *
 * Anyway, we need to be able to look at the entire string to remove leading whitespace,
 * but the following parsing functions need to see what's been removed.
 * The expansion of tabs occurs in place.
 */
struct Line
{
public:
	/*!
	 * Given a string, return a list of Line structures, split
	 * by the \n characters present in the string.
	 */
	local fn split(src: string) Line[]
	{
		slines := wattSplit(src);
		lines := new Line[](slines.length);
		for (i: size_t = 0; i < lines.length; ++i) {
			lines[i].mStr = slines[i];
		}
		return lines;
	}

public:
	iterationCount: size_t;
	listCount: size_t;

private:
	mStr: string;  // The actual string.
	mStart: size_t;  // Where the advanced string starts.

public:
	fn set(str: string, idx: size_t)
	{
		mStr = str;
		mStart = idx;
	}

	@property fn unchanged() bool
	{
		return mStart == 0;
	}

	//! @return The advanced string.
	fn toString() string
	{
		return mStr[mStart .. $];
	}

	//! @return True if the advanced string is empty.
	@property fn empty() bool
	{
		return mStart >= mStr.length;
	}

	//! Length of the advanced portion.
	@property fn length() size_t
	{
		return mStr.length - mStart;
	}

	//! Retrieve the nth character from the start.
	fn opIndex(n: size_t) char
	{
		return mStr[mStart+n];
	}

	/*!
	 * Return a slice of the advanced string,
	 * starting from a (inclusive), going to b (exclusive).
	 * If the slice is out of range, an empty string will
	 * be returned.
	 */
	fn slice(a: size_t, b: size_t) string
	{
		if (a >= length || b >= length) {
			return "";
		}
		return mStr[mStart+a .. mStart+b];
	}

	/*!
	 * Advance the line forward by @p n characters.
	 * Tabs encountered will be expanded.
	 * If n is greater than the rest of the line, the result
	 * will be an empty string.
	 */
	fn advance(n: size_t)
	{
		if (empty) {
			return;
		}
		i: size_t = mStart;
		while (n > 0) {
			if (i >= mStr.length) {
				clear();
				return;
			}
			if (mStr[i] == '\t') {
				tabSize := 4 - (i % 4);
				mStr = mStr[0 .. i] ~ emptyString(tabSize) ~ mStr[i+1 .. $];
				delta := min(n, tabSize);
				n -= delta;
				i += delta;
			} else {
				n--;
				i++;
			}
		}
		mStart = i;
		if (mStart >= mStr.length) {
			clear();
		}
	}

	// Treating tabs as four spaces, how much whitespace is at the beginning of the advanced string.
	@property fn leadingWhitespace() size_t
	{
		return contiguousWhitespace(0);
	}

	@property fn realLeadingWhitespace() size_t
	{
		return realContiguousWhitespace(0);
	}

	// Considering the whole line, ignoring advancement.
	fn realContiguousWhitespace(a: size_t) size_t
	{
		n: size_t;
		i: size_t = a;
		while (i < mStr.length && isWhite(mStr[i])) {
			if (mStr[i] == '\t') {
				n += 4;
			} else {
				n++;
			}
			i++;
		}
		return n;
	}

	fn contiguousWhitespace(a: size_t) size_t
	{
		n: size_t;
		i: size_t = mStart + a;
		while (i < mStr.length && isWhite(mStr[i])) {
			if (mStr[i] == '\t') {
				n += 4;
			} else {
				n++;
			}
			i++;
		}
		return n;
	}

	//! Call advance while this line is non-empty and starts with whitespace.
	fn consumeWhitespace() size_t
	{
		n: size_t;
		while (!empty && isWhite(mStr[mStart])) {
			if (mStr[mStart] == '\t') {
				n += 4;
			} else {
				n++;
			}
			advance(1);
		}
		return n;
	}

	/*!
	 * Call advance if this line is non-empty and starts with a given character.
	 * @return True if the line was advanced.
	 */
	fn consumeChar(c: char) bool
	{
		if (empty || mStr[mStart] != c) {
			return false;
		}
		advance(1);
		return true;
	}

	//! Make this line empty.
	fn clear()
	{
		mStart = mStr.length;
	}

	/*! 
	 * Remove whitespace from both sides of the underlying string.
	 * The advanced string index is reset.
	 */
	fn strip()
	{
		mStr = wattStrip(mStr);
		mStart = 0;
	}

	/*!
	 * Replace @p a with @p b.
	 */
	fn replace(a: string, b: string)
	{
		mStr = wattReplace(mStr, a, b);
	}

	//! Remove (from the underlying string) any trailing whitespace characters.
	fn stripRight()
	{
		while (mStr.length > 0 && isWhite(mStr[$-1])) {
			mStr = mStr[0 .. $-1];
		}
	}

	// Remove (from the underlying string) the last character.
	fn removeLast()
	{
		if (mStr.length > 0) {
			mStr = mStr[0 .. $-1];
		}
	}
}

