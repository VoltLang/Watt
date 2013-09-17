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

bool isAlphaNum(dchar c)
{
	return isAlpha(c) || isDigit(c);
}

bool isAlpha(dchar c)
{
	return isLower(c) || isUpper(c);
}

bool isLower(dchar c)
{
	return c >= 'a' && c <= 'z';
}

bool isUpper(dchar c)
{
	return c >= 'A' && c <= 'Z';
}

bool isDigit(dchar c)
{
	return c >= '0' && c <= '9';
}

bool isOctalDigit(dchar c)
{
	return c >= '0' && c <= '7';
}

bool isHexDigit(dchar c)
{
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'f' || c >= 'A' && c <= 'F';
}

bool isWhite(dchar c)
{
	return c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\v' || c == '\n';
}

bool isControl(dchar c)
{
	return c < 32 || c == 127;
}

bool isPunctuation(dchar c)
{
	return !isAlphaNum(c) && !isWhite(c) && !isControl(c);
}

bool isPrintable(dchar c)
{
	return c >= 32 && c <= 126;
}

bool isASCII(dchar c)
{
	return c <= 127;
}

dchar toLower(dchar c)
{
	if (isUpper(c)) {
		return cast(dchar) (cast(int) c + ('a' - 'A'));
	}
	return c;
}

dchar toUpper(dchar c)
{
	if (isLower(c)) {
		return cast(dchar) (cast(int) c - ('a' - 'A'));
	}
	return c;
}

