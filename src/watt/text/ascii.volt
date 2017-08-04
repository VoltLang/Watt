// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
//! Functions for classifying characters in the ASCII range.
module watt.text.ascii;

enum HEX_DIGITS = "0123456789ABCDEF";
enum FULL_HEX_DIGITS = "0123456789ABCDEFabcdef";
enum DIGITS = "0123456789";
enum OCTAL_DIGITS = "01234567";
enum LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
enum LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
enum UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
enum WHITESPACE = " \t\v\r\n\f";
version (Windows) {
	enum NEWLINE = "\r\n";
} else {
	enum NEWLINE = "\n";
}

//! @Returns `true` if `c` is alphanumeric (a-z,A-Z,0-9).
fn isAlphaNum(c: dchar) bool
{
	return isAlpha(c) || isDigit(c);
}

//! @Returns `true` if `c` is alphabetical (a-z,A-Z).
fn isAlpha(c: dchar) bool
{
	return isLower(c) || isUpper(c);
}

//! @Returns `true` if `c` is lowercase alphabetical (a-z).
fn isLower(c: dchar) bool
{
	return c >= 'a' && c <= 'z';
}

//! @Returns `true` if `c` is uppercase alphabetical (A-Z).
fn isUpper(c: dchar) bool
{
	return c >= 'A' && c <= 'Z';
}

//! @Returns `true` if `c` is a digit (0-9).
fn isDigit(c: dchar) bool
{
	return c >= '0' && c <= '9';
}

//! @Returns `true` if `c` is an octal digit (0-7).
fn isOctalDigit(c: dchar) bool
{
	return c >= '0' && c <= '7';
}

//! @Returns `true` if `c` is a hex digit (0-9,a-f,A-F).
fn isHexDigit(c: dchar) bool
{
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F';
}

//! @Returns `true` if `c` is whitespace.
fn isWhite(c: dchar) bool
{
	return c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\v' || c == '\n';
}

//! @Returns `true` if `c` is a control character.
fn isControl(c: dchar) bool
{
	return c < 32 || c == 127;
}

//! @Returns `true` if `c` is punctuation.
fn isPunctuation(c: dchar) bool
{
	return !isAlphaNum(c) && !isWhite(c) && !isControl(c);
}

//! @Returns `true` if `c` is a printable character.
fn isPrintable(c: dchar) bool
{
	return c >= 32 && c <= 126;
}

//! @Returns `true` if `c` is an ASCII character.
fn isASCII(c: dchar) bool
{
	return c <= 127;
}

//! @Returns `c`, or `c` as a lowercase character if it's an uppercase character.
fn toLower(c: dchar) dchar
{
	if (isUpper(c)) {
		return cast(dchar) (cast(i32) c + ('a' - 'A'));
	}
	return c;
}

//! @Returns `c`, or `c` as an uppercase character if it's a lowercase character.
fn toUpper(c: dchar) dchar
{
	if (isLower(c)) {
		return cast(dchar) (cast(i32) c - ('a' - 'A'));
	}
	return c;
}

