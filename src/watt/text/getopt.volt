// Copyright © 2014-2015, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0)
//! A suite of functions for processing command line arguments in a simple way.
module watt.text.getopt;

import core.exception;
import core.varargs;

import watt.conv;
import watt.text.format;
import watt.text.string;
import watt.text.utf;


//! An exception thrown on errors.
class GetoptException : Exception
{
	//! Construct a GetoptException with an error message.
	this(msg: string)
	{
		super(msg);
	}
}

//! Removes up to two leading dashes from a string.
private fn removeDashes(s: string) string
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

//! Remove an element from an array and update a given index.
private fn remove(ref args: string[], ref index: size_t)
{
	args = args[0 .. index] ~ args[index + 1 .. $];
	index -= 1;
}

//! Remove two elemeents starting from index.
private fn removeTwo(ref args: string[], ref index: size_t)
{
	args = args[0 .. index] ~ args[index + 2 .. $];
	index -= 2;
}

//! Get all the flags described by a description, throws GetoptException on error.
private fn parseDescription(description: string) string[]
{
	flags := split(description, '|');
	if (flags.length == 0) {
		throw new GetoptException("getopt: invalid description");
	}
	return flags;
}

//! If s has an equals character, return everything to the right of it. Otherwise, "".
private fn equalParameter(s: string) string
{
	i: size_t;
	while (i < s.length) {
		if (decode(s, ref i) == '=') {
			return s[i .. $];
		}
	}
	return "";
}

// No argument getopt base implementation.
private fn getoptImpl(ref args: string[], description: string, dgt: scope dg())
{
	flags := parseDescription(description);
	for (i: size_t = 1; i < args.length; ++i) {
		arg := removeDashes(args[i]);
		foreach (flag; flags) {
			if (flag == arg) {
				dgt();
				remove(ref args, ref i);
				break;
			}
		}
	}
}

// Argument taking getopt base implementation.
private fn getoptImpl(ref args: string[], description: string, dgt: scope dg (string))
{
	flags := parseDescription(description);
	for (i: size_t = 1; i < args.length; ++i) {
		oneDash: bool = args[i].length > 2 && args[i][0] == '-' && args[i][1] != '-';
		arg := removeDashes(args[i]);
		foreach (flag; flags) {
			equals := equalParameter(arg);
			equalLeft := split(arg, '=')[0];
			if (equals.length > 0 && equalLeft == flag) {
				dgt(equals);
				remove(ref args, ref i);
			} else if (flag.length == 1 && oneDash && arg[0] == flag[0]) {
				dgt(arg[1 .. $]);
				remove(ref args, ref i);
			} else if (flag == arg) {
				if (i + 1 >= args.length) {
					throw new GetoptException(format("getopt: expected parameter for argument '%s'.", arg));
				}
				dgt(args[i + 1]);
				removeTwo(ref args, ref i);
			}
		}
	}
}

/*!
 * If a flag (described in `description`, separated by | characters) shows up in `args`[1 .. $], an argument is parsed
 * and put into `_string`. Both the flag and argument are then removed from `args`.
 *
 * String arguments can be supplied in multiple ways:
 *  - By being the next element: `["--string", "foo"] // _string is assigned "foo".`
 *  - By being divided by an = character: `["--string=foo"] // _string is assigned "foo".`
 * If the flag is one character (not counting the -), then it can be bundled into one: `["-s32"] // _string is assigned "32".` 
 */
fn getopt(ref args: string[], description: string, ref _string: string)
{
	fn dgt(param: string) { _string = param; }
	getoptImpl(ref args, description, dgt);
}

//! The same as above, but the result is passed through `watt.conv.toInt`.
fn getopt(ref args: string[], description: string, ref _int: i32)
{
	fn dgt(arg: string)
	{
		try {
			_int = toInt(arg);
		} catch (ConvException) {
			throw new GetoptException(format("getopt: expected integer argument for flag '%s'.", description));
		}
	}
	getopt(ref args, description, dgt);
}

/*!
 * Given an array of strings, args, and a list of strings separated by a | character, description,
 * remove any strings in `args[1 .. $]` that start with '-' and contain any of the description strings.
 *
 * Sets `_bool` to `true` if `args` was modified.
 */
fn getopt(ref args: string[], description: string, ref _bool: bool)
{
	fn dgt() { _bool = true; }
	getoptImpl(ref args, description, dgt);
}

//! Calls a delegate each time the flag appears.
fn getopt(ref args: string[], description: string, dgt: scope dg ())
{
	getoptImpl(ref args, description, dgt);
}

//! Calls a delegate with argument each time the flag appears.
fn getopt(ref args: string[], description: string, dgt: scope dg (string))
{
	getoptImpl(ref args, description, dgt);
}

/*!
 * Returns the first element in `args[1 .. $]` that starts with a -, or an empty string otherwise.
 *
 * This is intended for error handling purposes:
 *
 *      auto flag = remainingOptions(args);
 *      if (flag.length > 0) {
 *          // Error, unknown option flag.
 *      }
 */
fn remainingOptions(args: string[]) string
{
	foreach (arg; args[1 .. $]) {
		if (arg.length > 1 && arg[0] == '-') {
			return arg;
		}
	}
	return "";
}

