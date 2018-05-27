// Copyright 2016, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Functions for demangling Volt mangled symbols.
 *
 * Names of types and functions are processed during compilation,
 * to ensure they are unique. This module contains functions
 * for getting human readable information from these mangled names.
 */
module watt.text.demangle;

import core.exception : Exception;

import watt.conv : toInt;
import watt.text.ascii : isDigit;
import watt.text.sink : StringSink, Sink;
import watt.text.format : format;

/*!
 * Demangle a given mangled name.  
 * @Throws `Exception` if `mangledName` is not a valid Volt mangled name.
 * @Param mangledName The name to demangle.
 * @Returns A string containing the demangled version of `mangledName`.
 */
fn demangle(mangledName: const(char)[]) string
{
	return demangleImpl(mangledName:mangledName, abridged:false);
}

/*!
 * Demangle a given mangled name, but omit redundant information.
 */
fn demangleShort(mangledName: const(char)[]) string
{
	return demangleImpl(mangledName:mangledName, abridged:true);
}

private:

fn demangleImpl(mangledName: const(char)[], abridged: bool) string
{
	sink: StringSink;

	// Mangle type.
	match(ref mangledName, "Vf");
	sink.sink("fn ");

	// Function name.
	demangleName(sink.sink, ref mangledName, false);
	sink.sink("(");

	// Function arguments.
	if (mangledName.length > 0 && mangledName[0] == 'M') {
		// A method. Just treat it as anything other function.
		getFirst(ref mangledName, 1);
	}
	match(ref mangledName, "Fv");
	firstIteration := true;
	while (mangledName.length > 0 && mangledName[0] != 'Z') {
		if (!firstIteration) {
			sink.sink(", ");
		} else {
			firstIteration = false;
		}
		demangleType(sink.sink, ref mangledName, abridged);
	}
	sink.sink(")");

	// Return value.
	match(ref mangledName, "Z");
	if (mangledName[0] == 'v') {
		getFirst(ref mangledName, 1);
	} else {
		sink.sink(" ");
		demangleType(sink.sink, ref mangledName, abridged);
	}

	failIf(mangledName.length > 0, "unused input");
	return sink.toString();
}

// If b is true, throw an Exception with msg.
fn failIf(b: bool, msg: string)
{
	if (b) {
		throw new Exception(msg);
	}
}

// If the front of mangledName isn't str, throw an Exception.
fn match(ref mangledName: const(char)[], str: string)
{
	failIf(mangledName.length < str.length, "input too short");
	tag := getFirst(ref mangledName, str.length);
	failIf(tag != str, format("expected '%s'", str));
}

// Return the first n characters of mangledName.
fn getFirst(ref mangledName: const(char)[], n: size_t) const(char)[]
{
	failIf(mangledName.length < n, "input too short");
	str := mangledName[0 .. n];
	mangledName = mangledName[n .. $];
	return str;
}

/*
 * Given a mangledName with a digit in front, return the whole number,
 * and remove it from mangledName.
 */
fn getNumber(ref mangledName: const(char)[]) i32
{
	assert(mangledName[0].isDigit());
	digitSink: StringSink;
	do {
		digitSink.sink(getFirst(ref mangledName, 1));
	} while (mangledName.length > 0 && mangledName[0].isDigit());
	return toInt(digitSink.toString());
}

/*
 * Format the name section (3the3bit4that2is4like4this) to sink,
 * and remove it from mangledName.
 */
fn demangleName(sink: Sink, ref mangledName: const(char)[], abridged: bool)
{
	firstIteration := true;
	nameSink: StringSink;
	lastSegment, secondToLastSegment: const(char)[];
	while (mangledName[0].isDigit()) {
		if (!firstIteration) {
			nameSink.sink(".");
		} else {
			firstIteration = false;
		}

		sectionLength := cast(size_t)getNumber(ref mangledName);
		failIf(mangledName.length < sectionLength, "input too short");
		secondToLastSegment = lastSegment;
		lastSegment = getFirst(ref mangledName, sectionLength);
		nameSink.sink(lastSegment);
	}
	if (!abridged) {
		nameSink.toSink(sink);
	} else {
		if (mangledName.length > 0 && mangledName[0] == 'M') {
			sink(secondToLastSegment);
			sink(".");
		}
		sink(lastSegment);
	}
}

/*
 * Format a type from mangledName (e.g. i => i32), add it to the sink,
 * and remove it from mangledName.
 */
fn demangleType(sink: Sink, ref mangledName: const(char)[], abridged: bool)
{
	t := getFirst(ref mangledName, 1);
	switch (t) {
	case "B": sink("bool"); break;
	case "b": sink("i8"); break;
	case "s": sink("i16"); break;
	case "i": sink("i32"); break;
	case "l": sink("i64"); break;
	case "c": sink("char"); break;
	case "w": sink("wchar"); break;
	case "d": sink("dchar"); break;
	case "v": sink("void"); break;
	case "u":
		t2 := getFirst(ref mangledName, 1);
		switch (t2) {
		case "b": sink("u8"); break;
		case "s": sink("u16"); break;
		case "i": sink("u32"); break;
		case "l": sink("u64"); break;
		default: throw new Exception(format("unknown type string %s%s", t, t2));
		}
		break;
	case "f":
		t2 := getFirst(ref mangledName, 1);
		switch (t2) {
		case "f": sink("f32"); break;
		case "d": sink("f64"); break;
		case "r": throw new Exception("invalid type string 'fr', denotes obsolete 'real'");
		default: throw new Exception(format("unknown type string %s%s", t, t2));
		}
		break;
	case "p":
		demangleType(sink, ref mangledName, abridged);
		sink("*");
		break;
	case "a":
		if (abridged && mangledName.length >= 2 && mangledName[0 .. 2] == "mc") {
			getFirst(ref mangledName, 2);
			sink("string");
			break;
		}
		isStatic := false;
		staticLength: i32;
		if (mangledName.length > 1 && mangledName[0] == 't' && mangledName[1].isDigit()) {
			getFirst(ref mangledName, 1);
			staticLength = getNumber(ref mangledName);
			isStatic = true;
		}
		demangleType(sink, ref mangledName, abridged);
		if (!isStatic) {
			sink("[]");
		} else {
			sink(format("[%s]", staticLength));
		}
		break;
	case "o":
		sink("const(");
		demangleType(sink, ref mangledName, abridged);
		sink(")");
		break;
	case "m":
		sink("immutable(");
		demangleType(sink, ref mangledName, abridged);
		sink(")");
		break;
	case "e":
		sink("scope(");
		demangleType(sink, ref mangledName, abridged);
		sink(")");
		break;
	case "r":
		sink("ref ");
		demangleType(sink, ref mangledName, abridged);
		break;
	case "O":
		sink("out ");
		demangleType(sink, ref mangledName, abridged);
		break;
	case "A":
		match(ref mangledName, "a");
		keySink: StringSink;
		demangleType(keySink.sink, ref mangledName, abridged);

		demangleType(sink, ref mangledName, abridged);
		sink("[");
		keySink.toSink(sink);
		sink("]");
		break;
	case "F":
		demangleFunctionType(sink, ref mangledName, "fn", abridged);
		break;
	case "D":
		demangleFunctionType(sink, ref mangledName, "dg", abridged);
		break;
	case "S":  // Struct
	case "C":  // Class
	case "U":  // Union
	case "E":  // Enum
	case "I":  // Interface
		demangleName(sink, ref mangledName, abridged);
		break;
	default: throw new Exception(format("unknown type string %s", t));
	}
}

fn demangleFunctionType(sink: Sink, ref mangledName: const(char)[], keyword: string, abridged: bool)
{
	getFirst(ref mangledName, 1);  // Eat calling convention ('v', etc).
	sink(format("%s(", keyword));
	firstIteration := true;
	while (mangledName.length > 0 && mangledName[0] != 'Z') {
		if (!firstIteration) {
			sink(", ");
		} else {
			firstIteration = false;
		}
		demangleType(sink, ref mangledName, abridged);
	}
	sink(")");
	match(ref mangledName, "Z");
	if (mangledName.length > 0 && mangledName[0] != 'v') {
		sink(" ");
		demangleType(sink, ref mangledName, abridged);
	}
}
