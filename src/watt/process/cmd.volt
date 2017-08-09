// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Functions for parsing a command string.
 *
 * These don't actually run any commands, but are useful for dealing
 * with functions that do run a command string.
 */
module watt.process.cmd;

import watt.text.utf;
import watt.text.sink;
import watt.text.ascii;


/*!
 * Surround the string with " and escape " and /.
 *
 * `str` is surrounded by `"`. Any `"` present in `str` will
 * be preceded by `\`, as will any `\` characters.
 *
 * ### Examples
 * ```volt
 * escapeAndAddQuotation(sink, `hello`);     // "hello"
 * escapeAndAddQuotation(sink, `"hel\lo"`);  // "\"hel\\lo\""
 * ```
 */
fn escapeAndAddQuotation(sink: Sink, str: SinkArg) void
{
	sink(`"`);
	foreach (dchar d; str) {
		switch (d) {
			case '"': sink(`\"`); continue;
			case '\\': sink(`\\`); continue;
			default: encode(sink, d);
		}
	}
	sink(`"`);
}

/*!
 * Returns a textual representation of `cmd` and `args`
 * that can be passed to "/bin/sh -c".
 *
 * Given an array of strings (say from @ref watt.process.cmd.parseArguments)
 * create a C string with the elements separated by spaces and quotes as appropriate.
 */
fn toArgsPosix(cmd: SinkArg, args: SinkArg[]) char*
{
	sink: StringSink;

	escapeAndAddQuotation(sink.sink, cmd);
	foreach (arg; args) {
		sink.sink(" ");
		escapeAndAddQuotation(sink.sink, arg);
	}
	sink.sink("\0");

	return sink.toChar().ptr;
}

/*
 * State for parsing 
 */
private enum ArgumentParseState {
	WHITESPACE, // Skipping whitespace.
	NORMAL,     // Regular text.
	ESCAPE,     // A '\' next char always added.
	IGNORE,     // Inside a " field (add whitespace).
}

/*!
 * Parse a string as a series of arguments, like bash/make does.
 *
 * - The words in `str` are split by whitespace.
 * - Whitespace isn't included unless it's in a string literal,
 * which uses the `"` character.
 *
 * ### Example
 * ```volt
 * parseArguments(`a   b	c "d e f"`);  // Returns ["a", "b", "c", "d e f"]
 * ```
 */
fn parseArguments(str: SinkArg) string[]
{
	pos: size_t;
	ret: string[];
	tmp := new char[](str.length);

	state := ArgumentParseState.WHITESPACE;
	stateOld := state;

	fn escape() void {
		stateOld = state;
		state = ArgumentParseState.ESCAPE;
	}

	fn add(c: char) void {
		tmp[pos++] = c;
	}

	fn done() void {
		if (pos == 0) {
			return;
		}
		ret ~= new string(tmp[0 .. pos]);
		pos = 0;
	}

	// We use char here because we don't know what kind of invalid
	// utf8 gets thrown at use via the command line.
	foreach (char c; str) {
		switch (state) with (ArgumentParseState) {
		case WHITESPACE:
			if (isWhite(c)) {
				continue;
			} else if (c == '\\') {
				escape();
			} else if (c == '"') {
				state = IGNORE;
			} else {
				add(c);
				state = NORMAL;
			}
			break;
		case NORMAL:
			if (isWhite(c)) {
				done();
				state = WHITESPACE;
			} else if (c == '\\') {
				escape();
			} else if (c == '"') {
				state = IGNORE;
			} else {
				add(c);
			}
			break;
		case ESCAPE:
			if (c != '\n') {
				add(c);
			}

			if (stateOld == IGNORE) {
				state = IGNORE;
			} else {
				state = NORMAL;
			}
			break;
		case IGNORE:
			if (c == '\\') {
				escape();
			} else if (c == '"') {
				state = NORMAL;
			} else {
				add(c);
			}
			break;
		default:
			assert(false);
		}
	}

	// If we are parsing normal or have a uncompleted '"' add it.
	if (state == ArgumentParseState.NORMAL ||
	    state == ArgumentParseState.IGNORE) {
		done();
	}

	return ret;
}
