// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
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

fn isAlphaNum(c: dchar) bool
{
	return isAlpha(c) || isDigit(c);
}

fn isAlpha(c: dchar) bool
{
	return isLower(c) || isUpper(c);
}

fn isLower(c: dchar) bool
{
	return c >= 'a' && c <= 'z';
}

fn isUpper(c: dchar) bool
{
	return c >= 'A' && c <= 'Z';
}

fn isDigit(c: dchar) bool
{
	return c >= '0' && c <= '9';
}

fn isOctalDigit(c: dchar) bool
{
	return c >= '0' && c <= '7';
}

fn isHexDigit(c: dchar) bool
{
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F';
}

fn isWhite(c: dchar) bool
{
	return c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\v' || c == '\n';
}

fn isControl(c: dchar) bool
{
	return c < 32 || c == 127;
}

fn isPunctuation(c: dchar) bool
{
	return !isAlphaNum(c) && !isWhite(c) && !isControl(c);
}

fn isPrintable(c: dchar) bool
{
	return c >= 32 && c <= 126;
}

fn isASCII(c: dchar) bool
{
	return c <= 127;
}

fn toLower(c: dchar) dchar
{
	if (isUpper(c)) {
		return cast(dchar) (cast(i32) c + ('a' - 'A'));
	}
	return c;
}

fn toUpper(c: dchar) dchar
{
	if (isLower(c)) {
		return cast(dchar) (cast(i32) c - ('a' - 'A'));
	}
	return c;
}

