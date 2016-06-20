// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.cmd;

import watt.text.utf;
import watt.text.sink;


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

