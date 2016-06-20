// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.cmd;

import watt.text.utf;
import watt.text.sink;
import watt.text.ascii;


/**
 * Surround the string with " and escape " and / with /.
 */
void escapeAndAddQuotation(Sink sink, SinkArg str)
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

/**
 * Returns a textual representation of the command and args
 * that can be passed to "/bin/sh -c".
 */
char* toArgsPosix(SinkArg cmd, SinkArg[] args)
{
	StringSink sink;

	escapeAndAddQuotation(sink.sink, cmd);
	foreach (arg; args) {
		sink.sink(" ");
		escapeAndAddQuotation(sink.sink, arg);
	}
	sink.sink("\0");

	return sink.toChar().ptr;
}

/**
 * State for parsing 
 */
private enum ArgumentParseState {
	WHITESPACE, // Skipping whitespace.
	NORMAL,     // Regular text.
	ESCAPE,     // A '\' next char always added.
	IGNORE,     // Inside a " field (add whitespace).
}

/**
 * Parser a string as a series of arguments, just like bash/make does.
 */
string[] parseArguments(SinkArg str)
{
	pos : size_t;
	ret : string[];
	tmp := new char[](str.length);

	state := ArgumentParseState.WHITESPACE;
	stateOld := state;

	void escape() {
		stateOld = state;
		state = ArgumentParseState.ESCAPE;
	}

	void add(char c) {
		tmp[pos++] = c;
	}

	void done() {
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
			add(c);
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
