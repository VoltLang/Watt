// Copyright © 2017, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
module watt.text.semver;

import core.exception;
import core.object;
import watt.conv;
import watt.text.ascii;
import watt.text.format;
import watt.text.string;

/*!
 * Parses a string into a Semantic Version. (semver.org)
 */
class Release
{
public:
	//! <major>.<minor>.<patch>(-<prerelease>)(+<metadata>)
	major: i32;
	minor: i32;
	patch: i32;
	prerelease: string;
	metadata: string;

public:
	/*!
	 * Parse a SemVer from a given string.
	 * Throws: Exception on malformed input.
	 */
	this(verString: string)
	{
		retval := parse(verString);
		if (!retval) {
			throw new Exception(mFailureString);
		}
	}

	/*!
	 * Returns true if the given string is a valid semver string.
	 */
	local fn isValid(verString: string) bool
	{
		// TODO: Make this `new Release()` once we can make a private noarg ctor.
		sv := new Release("1.2.3");
		return sv.parse(verString);
	}

public:
	override fn toString() string
	{
		return format("%s.%s.%s%s%s",
			major, minor, patch,
			prerelease.length > 0 ? format("-%s", prerelease) : "",
			metadata.length > 0 ? format("+%s", metadata) : "");
	}

	fn opCmp(b: Release) i32
	{
		retval := componentCheck(this.major, b.major);
		if (retval != 0) {
			return retval;
		}
		retval = componentCheck(this.minor, b.minor);
		if (retval != 0) {
			return retval;
		}
		retval = componentCheck(this.patch, b.patch);
		if (retval != 0) {
			return retval;
		}
		if (this.prerelease.length > 0 && b.prerelease.length == 0) {
			return -1;
		}
		return prereleaseCheck(this.prerelease, b.prerelease);
	}

	fn opEquals(b: Release) bool
	{
		return opCmp(b) == 0;
	}

private:
	//! Upon failure, this contains a reason for the user.
	mFailureString: string;

private:
	fn componentCheck(a: i32, b: i32) i32
	{
		if (a < b) {
			return -1;
		} else if (a > b) {
			return 1;
		}
		return 0;
	}

	fn prereleaseCheck(a: string, b: string) i32
	{
		aidents := a.split('.');
		bidents := b.split('.');
		foreach (i, aident; aidents) {
			if (i >= bidents.length) {
				return 1;
			}
			bident := bidents[i];
			anumeric := onlyDigits(aident);
			bnumeric := onlyDigits(bident);
			if (anumeric && !bnumeric) {
				return -1;
			}
			if (!anumeric && bnumeric) {
				return 1;
			}
			if (anumeric && bnumeric) {
				ai := toInt(aident);
				bi := toInt(bident);
				if (ai > bi) {
					return 1;
				} else if (ai < bi) {
					return -1;
				} else {
					continue;
				}
			}
			foreach (ii, c: char; aident) {
				if (ii >= bident.length) {
					return 1;
				}
				if (aident[ii] > bident[ii]) {
					return 1;
				} else if (aident[ii] < bident[ii]) {
					return -1;
				}
			}
			if (bident.length > aident.length) {
				return -1;
			}
		}
		return bidents.length > aidents.length ? -1 : 0;
	}

	fn onlyDigits(a: string) bool
	{
		foreach (c: char; a) {
			if (!isDigit(c)) {
				return false;
			}
		}
		return true;
	}

	// Parse a given semver string. Returns true on success.
	fn parse(s: string) bool
	{
		retval := parseNumberAndDot(ref s, out major);
		if (!retval) {
			return false;
		}
		retval = parseNumberAndDot(ref s, out minor);
		if (!retval) {
			return false;
		}
		retval = parseNumber(ref s, out patch);
		if (!retval) {
			return false;
		}
		if (s.length == 0) {
			return true;
		}
		if (s[0] == '-') {
			retval = parseAddendum(ref s, '-', out prerelease);
			if (!retval) {
				return false;
			}
		}
		retval = parseAddendum(ref s, '+', out metadata);
		if (!retval) {
			return false;
		}
		if (s.length != 0) {
			mFailureString = format("additional characters '%s' on end of string", s);
			return false;
		}
		return true;
	}

	fn parseNumberAndDot(ref s: string, out i: i32) bool
	{
		retval := parseNumber(ref s, out i);
		if (!retval) {
			return false;
		}
		retval = parseChar(ref s, '.');
		if (!retval) {
			return false;
		}
		return true;
	}

	// Parse digits until the end of string, or a dot.
	fn parseNumber(ref s: string, out val: i32) bool
	{
		fn fail() bool
		{
			mFailureString = "expected digit, '.', or end of string";
			return false;
		}
	
		if (s.length == 0 || !isDigit(s[0])) {
			return fail();
		}
		idx: size_t;
		while (isDigit(s[idx])) {
			idx++;  // If it's not ascii, it's not valid.
		}
		val = toInt(s[0 .. idx]);
		assert(val >= 0);
		s = s[idx .. $];
		return true;
	}

	fn parseChar(ref s: string, c: dchar) bool
	{
		fn fail() bool
		{
			mFailureString = format("expected '%c'", c);
			return false;
		}

		if (s.length == 0) {
			return fail();
		}
		cc := s[0];
		if (cc != c) {
			return fail();
		}
		s = s[1 .. $];
		return true;
	}

	fn parseAddendum(ref s: string, startC: dchar, out sval: string) bool
	{
		fn valid(c: dchar) bool
		{
			return isAlphaNum(c) || c == '-' || c == '.';
		}

		if (s.length == 0) {
			return true;
		}
		retval := parseChar(ref s, startC);
		if (!retval) {
			return false;
		}
		idx: size_t;
		while (valid(s[idx])) {
			idx++;
		}
		if (idx == 0) {
			mFailureString = "expected alpha numeric or '-'";
			return false;
		}
		sval = s[0 .. idx];
		s = s[idx .. $];
		return true;	
	}
}
