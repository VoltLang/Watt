// Copyright 2014-2015, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Process command line arguments.
 *
 * The `getopt` modules provides functions that make handling command line options easy.
 *
 * The basic approach is to call `getopt` functions with the `args` parameter, a flag description,
 * and a parameter that determines what `getopt` will do if it finds a matching parameter.  
 * Matching parameters are removed from the given `args` array. 
 * 
 * ```volt
 * getopt(ref args, "help|h", delegateThatPrintsUsage);
 * getopt(ref args, "verbose|v", out booleanVariable);
 * ```
 *
 * The flag description format is simple. It's just the flag name:
 * ```volt
 * "help"
 * ```
 *
 * You can add aliases to the same flag by separating them with a `|`:
 * ```volt
 * "help|usage|?|h"
 * ```
 *
 * Single character flags can be preceded by a a single dash.
 * If a flag takes an argument, it can be specified multiple ways. A value 
 * can be separated from the flag by `=`, or whitespace.  
 * If the flag is a single character, the value can be bundled together:
 * ```volt
 * -i32
 * ```
 */
module watt.text.getopt;

import core.exception;
import core.varargs;

import watt.conv;
import watt.text.format;
import watt.text.string;
import watt.text.utf;


//! Thrown when arguments are in error.
class GetoptException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

// Removes up to two leading dashes from a string.
private fn removeDashes(s: string, ref dashesRemoved: i32) string
{
	dashesRemoved = 0;
	if (s.length == 0 || (s.length == 1 && s[0] == '-') || (s.length == 2 && s == "--")) {
		return "";
	}
	if (s.length >= 2 && s[0 .. 2] == "--") {
		dashesRemoved = 2;
		return s[2 .. $];
	} else if (s.length >= 1 && s[0 .. 1] == "-") {
		dashesRemoved = 1;
		return s[1 .. $];
	} else {
		return s;
	}
}

// Remove an element from an array and update a given index.
private fn remove(ref args: string[], ref index: size_t)
{
	args = args[0 .. index] ~ args[index + 1 .. $];
	index -= 1;
}

// Remove two elemeents starting from index.
private fn removeTwo(ref args: string[], ref index: size_t)
{
	args = args[0 .. index] ~ args[index + 2 .. $];
	index -= 2;
}

// Get all the flags described by a description, throws GetoptException on error.
private fn parseDescription(description: string) string[]
{
	flags := split(description, '|');
	if (flags.length == 0) {
		throw new GetoptException("getopt: invalid description");
	}
	return flags;
}

// If s has an equals character, return everything to the right of it. Otherwise, "".
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
private fn getoptImpl(ref args: string[], description: string, dgt: scope dg()) bool
{
	removed := false;
	flags := parseDescription(description);
	for (i: size_t = 0; i < args.length; ++i) {
		dashesRemoved: i32;
		arg := removeDashes(args[i], ref dashesRemoved);
		if (dashesRemoved == 0 || (arg.length > 1 && dashesRemoved != 2)) {
			continue;
		}
		foreach (flag; flags) {
			if (flag == arg) {
				dgt();
				remove(ref args, ref i);
				removed = true;
				break;
			}
		}
	}
	return removed;
}

// Argument taking getopt base implementation.
private fn getoptImpl(ref args: string[], description: string, dgt: scope dg (string)) bool
{
	removed := false;
	flags := parseDescription(description);
	for (i: size_t = 0; i < args.length; ++i) {
		dashesRemoved: i32;
		arg := removeDashes(args[i], ref dashesRemoved);
		if (dashesRemoved == 0) {
			continue;
		}
		foreach (flag; flags) {
			equals := equalParameter(arg);
			equalLeft := split(arg, '=')[0];
			if (equals.length > 0 && equalLeft == flag) {
				// Flag with equals between argument, a la '--name=boggyb'
				dgt(equals);
				remove(ref args, ref i);
				removed = true;
				break;
			} else if (flag.length == 1 && dashesRemoved == 1 && arg[0] == flag[0] && arg != flag) {
				// Combined flag with argument, a la '-j2'
				dgt(arg[1 .. $]);
				remove(ref args, ref i);
				removed = true;
				break;
			} else if (flag == arg) {
				// Flag, then argument, a la '-j 2'
				if (i + 1 >= args.length) {
					throw new GetoptException(format("getopt: expected parameter for argument '%s'.", arg));
				}
				dgt(args[i + 1]);
				removeTwo(ref args, ref i);
				removed = true;
				break;
			}
		}
	}
	return removed;
}

/*!
 * Parse a flag taking a string argument from an array of strings.
 *
 * If a flag (described in `description`, separated by | characters) shows up in `args`[1 .. $], an argument is parsed
 * and put into `_string`. Both the flag and argument are then removed from `args`.
 * If there are multiple instances of the flag, `_string` will have the value of the last
 * instance.
 *
 * @Param args The array of strings to remove applicable flags and arguments from.
 * @Param description The description of the flag -- see `getopt`'s module documentation for details.
 * @Param _string This argument will be filled with the last value parsed out of `args`.
 * @Returns `true` if an argument was removed from `args`.
 */
fn getopt(ref args: string[], description: string, ref _string: string) bool
{
	_string = null;
	fn dgt(param: string) { _string = param; }
	return getoptImpl(ref args, description, dgt);
}

/*!
 * Parse a flag that takes an integer argument from an array of strings.
 *
 * @Param args The array of strings to remove flags and arguments from.
 * @Param description The description of the flag -- see `getopt`'s module documentation for details.
 * @Param _int This argument will be filled with the last value parsed out of `args`.
 * @Returns `true` if an argument was removed from `args`.
 * @Throws `GetoptException` if the argument could not be parsed as an integer.
 */
fn getopt(ref args: string[], description: string, ref _int: i32) bool
{
	_int = 0;
	fn dgt(arg: string)
	{
		try {
			_int = toInt(arg);
		} catch (ConvException) {
			throw new GetoptException(format("getopt: expected integer argument for flag '%s'.", description));
		}
	}
	return getopt(ref args, description, dgt);
}

/*!
 * Handle a simple boolean flag.
 *
 * Given an array of strings, args, and a list of strings separated by a | character, description,
 * remove any strings in `args[1 .. $]` that start with '-' and contain any of the description strings.
 *
 * Sets `_bool` to `true` if `args` was modified, and returns the same value.
 */
fn getopt(ref args: string[], description: string, ref _bool: bool) bool
{
	_bool = false;
	fn dgt() { _bool = true; }
	return getoptImpl(ref args, description, dgt);
}

/*!
 * Calls a delegate each time the flag appears.
 *
 * The found flags are removed from `args`.
 *
 * @Returns `true` if anything was removed from `args`.
 */
fn getopt(ref args: string[], description: string, dgt: scope dg ()) bool
{
	return getoptImpl(ref args, description, dgt);
}

/*!
 * Calls a delegate with argument each time the flag appears.
 *
 * The flag and arguments are removed from the `args` array.
 *
 * @Returns `true` if anything was removed from `args`.
 */
fn getopt(ref args: string[], description: string, dgt: scope dg (string)) bool
{
	return getoptImpl(ref args, description, dgt);
}

/*!
 * Get the first flag in an array of `string`s.
 *
 * Gets the first element in `args[1 .. $]` that starts with a -, or an empty string otherwise.
 *
 * This is intended for error handling purposes:
 * ```volt
 * auto flag = remainingOptions(args);
 * if (flag.length > 0) {
 *     writefln("error, unknown flag '%s'", flag);
 * }
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
