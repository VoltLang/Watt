// Copyright © 2014-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
// Command line options parser.
module watt.text.getopt;

import object;
import watt.conv;
import watt.varargs;
import watt.text.format;
import watt.text.string;
import watt.text.utf;
import watt.io;

/// An exception thrown on errors.
class GetoptException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

/// Removes up to two leading dashes from a string.
private string removeDashes(string s)
{
	if (s.length == 0 || (s.length == 1 && s[0] == '-') || (s.length == 2 && s == "--")) {
		return "";
	}
	if (s.length >= 2 && s[0 .. 2] == "--") {
		return s[2 .. $];
	} else if (s.length >= 1 && s[0 .. 1] == "-") {
		return s[1 .. $];
	} else {
		return s;
	}
}

/// Remove an element from an array and update a given index.
private void remove(ref string[] args, ref size_t index)
{
	args = args[0 .. index] ~ args[index + 1 .. $];
	index -= 1;
}

/// Remove two elemeents starting from index.
private void removeTwo(ref string[] args, ref size_t index)
{
	args = args[0 .. index] ~ args[index + 2 .. $];
	index -= 2;
}

/// Get all the flags described by a description, throws GetoptException on error.
private string[] parseDescription(string description)
{
	auto flags = split(description, '|');
	if (flags.length == 0) {
		throw new GetoptException("getopt: invalid description");
	}
	return flags;
}

/// If s has an equals character, return everything to the right of it. Otherwise, "".
private string equalParameter(string s)
{
	size_t i;
	while (i < s.length) {
		if (decode(s, ref i) == '=') {
			return s[i .. $];
		}
	}
	return "";
}

// No argument getopt base implementation.
private void getoptImpl(ref string[] args, string description, scope void delegate() dg)
{
	auto flags = parseDescription(description);
	for (size_t i = 1; i < args.length; ++i) {
		auto arg = removeDashes(args[i]);
		foreach (flag; flags) {
			if (flag == arg) {
				dg();
				remove(ref args, ref i);
				break;
			}
		}
	}
}

// Argument taking getopt base implementation.
void getoptImpl(ref string[] args, string description, scope void delegate(string) dg)
{
	auto flags = parseDescription(description);
	for (size_t i = 1; i < args.length; ++i) {
		bool oneDash = args[i].length > 2 && args[i][0] == '-' && args[i][1] != '-';
		auto arg = removeDashes(args[i]);
		foreach (flag; flags) {
			auto equals = equalParameter(arg);
			auto equalLeft = split(arg, '=')[0];
			if (equals.length > 0 && equalLeft == flag) {
				dg(equals);
				remove(ref args, ref i);
			} else if (flag.length == 1 && oneDash && arg[0] == flag[0]) {
				dg(arg[1 .. $]);
				remove(ref args, ref i);
			} else if (flag == arg) {
				if (i + 1 >= args.length) {
					throw new GetoptException(format("getopt: expected parameter for argument '%s'.", arg));
				}
				dg(args[i + 1]);
				removeTwo(ref args, ref i);
			}
		}
	}
}

/**
 * If a flag (described in description, separated by | characters) shows up in args[1 .. $], an argument is parsed
 * and put into _string. Both the flag and argument are then removed from args.
 * String arguments can be supplied in multiple ways:
 *  By being the next element ["--string", "foo"] // _string is assigned "foo".
 *  By being divided by an = character ["--string=foo"] // _string is assigned "foo".
 *  If the flag is one character (not counting the -), then it can be bundled into one ["-s32"] // _string is assigned "32". 
 */
void getopt(ref string[] args, string description, ref string _string)
{
	void dg(string param) { _string = param; }
	getoptImpl(ref args, description, dg);
}

/// The same as getopt with string, but the result is passed through watt.conv.toInt.
void getopt(ref string[] args, string description, ref int _int)
{
	void dg(string arg)
	{
		try {
			_int = toInt(arg);
		} catch (ConvException) {
			throw new GetoptException(format("getopt: expected integer argument for flag '%s'.", description));
		}
	}
	getopt(ref args, description, dg);
}

/**
 * Given an array of strings, args, and a list of strings separated by a | character, description,
 * remove any strings in args[1 .. $] that start with '-' and contain any of the description strings.
 * Sets _bool to true if args was modified.
 */
void getopt(ref string[] args, string description, ref bool _bool)
{
	void dg() { _bool = true; }
	getoptImpl(ref args, description, dg);
}

/// Calls a delegate each time the flag appears.
void getopt(ref string[] args, string description, scope void delegate() dg)
{
	getoptImpl(ref args, description, dg);
}

/// Calls a delegate with argument each time the flag appears.
void getopt(ref string[] args, string description, scope void delegate(string) dg)
{
	getoptImpl(ref args, description, dg);
}

/**
 * Returns the first element in args[1 .. $] that starts with a -, or an empty string otherwise.
 * This is intended for error handling purposes:
 *     auto flag = remainingOptions(args);
 *     if (flag.length > 0) {
 *         // Error, unknown option flag.
 *     }
 */
string remainingOptions(string[] args)
{
	foreach (arg; args[1 .. $]) {
		if (arg.length > 1 && arg[0] == '-') {
			return arg;
		}
	}
	return "";
}

