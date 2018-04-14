// Copyright 2013, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Functions for classifying `characters` in the ASCII range.
 *
 * Despite the name, you can pass any UTF-8 characters to these functions.
 * It's just that none of them will be considered true. Unicode whitespace
 * won't return `true` from @ref watt.text.ascii.isWhite, etc.
 */
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

/*!
 * Is a character alphanumeric?
 * ### Examples
 * ```volt
 * isAlphaNum('a');  // true
 * isAlphaNum('A');  // true
 * isAlphaNum('2');  // true
 * isAlphaNum('あ'); // false
 * isAlphaNum('!');  // false
 * ```
 * @Returns `true` if `c` is alphanumeric (a-z,A-Z,0-9).
 */
fn isAlphaNum(c: dchar) bool
{
	return isAlpha(c) || isDigit(c);
}

/*!
 * Is a character alphabetical?
 * ### Examples
 * ```volt
 * isAlpha('a');  // true
 * isAlpha('G');  // true
 * isAlpha('2');  // false
 * ```
 * @Returns `true` if `c` is alphabetical (a-z,A-Z).
 */
fn isAlpha(c: dchar) bool
{
	return isLower(c) || isUpper(c);
}

/*!
 * Is a character a lowercase alphabetical character?
 * ### Examples
 * ```volt
 * isLower('a');  // true
 * isLower('A');  // false
 * ```
 * @Returns `true` if `c` is lowercase alphabetical (a-z).
 */
fn isLower(c: dchar) bool
{
	return c >= 'a' && c <= 'z';
}

/*!
 * Is a character a uppercase alphabetical character?
 * ### Examples
 * ```volt
 * isLower('a');  // false
 * isLower('A');  // true
 * ```
 * @Returns `true` if `c` is uppercase alphabetical (A-Z).
 */
fn isUpper(c: dchar) bool
{
	return c >= 'A' && c <= 'Z';
}

/*!
 * Is a character a digit?
 * ### Examples
 * ```volt
 * isDigit('4');  // true
 * isDigit('(');  // false
 * ```
 * @Returns `true` if `c` is a digit (0-9).
 */
fn isDigit(c: dchar) bool
{
	return c >= '0' && c <= '9';
}

/*!
 * Is a character an octal digit?
 * ### Examples
 * ```volt
 * isOctalDigit('7');  // true
 * isOctalDigit('8');  // false
 * ```
 * @Returns `true` if `c` is an octal digit (0-7).
 */
fn isOctalDigit(c: dchar) bool
{
	return c >= '0' && c <= '7';
}

/*!
 * Is a character a hexadecimal digit?
 * ### Examples
 * ```volt
 * isHexDigit('1');  // true
 * isHexDigit('f');  // true
 * isHexDigit('F');  // true
 * isHexDigit('g');  // false
 * ```
 * @Returns `true` if `c` is a hex digit (0-9,a-f,A-F).
 */
fn isHexDigit(c: dchar) bool
{
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F';
}

/*!
 * Is a character whitespace?
 *
 * The characters considered whitespace are ` `, `\t`, `\r`, `\f`, `\v`, and `\n`.
 * @Returns `true` if `c` is whitespace.
 */
fn isWhite(c: dchar) bool
{
	return c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\v' || c == '\n';
}

/*!
 * Is a character a control character?
 *
 * A control character is a non printing character. Non ascii characters are not considered,
 * so any value over `127` will not be considered to be a control character.
 * @Returns `true` if `c` is a control character.
 */
fn isControl(c: dchar) bool
{
	return c < 32 || c == 127;
}

/*!
 * Is a character punctuation?
 *
 * Where punctuation is defined as a non control, non whitespace, non alphanumeric
 * character.
 *
 * @Returns `true` if `c` is punctuation.
 */
fn isPunctuation(c: dchar) bool
{
	return !isAlphaNum(c) && !isWhite(c) && !isControl(c);
}

/*!
 * Is a character a printable ASCII character?
 *
 * @Returns `true` if `c` is a printable character.
 */
fn isPrintable(c: dchar) bool
{
	return c >= 32 && c <= 126;
}

/*!
 * Is a given character an ASCII character?
 * ### Examples
 * ```volt
 * isASCII('a');  // true
 * isASCII('楽');  // false
 * ```
 * @Returns `true` if `c` is an ASCII character.
 */
fn isASCII(c: dchar) bool
{
	return c <= 127;
}

/*!
 * Get the lowerspace letter of an uppercase character.
 * ### Examples
 * ```volt
 * toLower('A');  // 'a'
 * toLower('a');  // 'a'
 * toLower('2');  // '2'
 * ```
 * @Returns `c`, or `c` as a lowercase character if it's an uppercase character.
 */
fn toLower(c: dchar) dchar
{
	if (isUpper(c)) {
		return cast(dchar) (cast(i32) c + ('a' - 'A'));
	}
	return c;
}

/*!
 * Get the upperspace letter of a lowercase character.
 * ### Examples
 * ```volt
 * toLower('A');  // 'A'
 * toLower('a');  // 'A'
 * toLower('2');  // '2'
 * ```
 * @Returns `c`, or `c` as an uppercase character if it's a lowercase character.
 */
fn toUpper(c: dchar) dchar
{
	if (isLower(c)) {
		return cast(dchar) (cast(i32) c - ('a' - 'A'));
	}
	return c;
}

