// Copyright © 2017, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Uses the event parser to parse TOML into a tree in memory.
module watt.toml.tree;

import algo = watt.algorithm;
import event = watt.toml.event;
import text = watt.text.string;
import ascii = watt.text.ascii;
import source = watt.text.source;
import sink = watt.text.sink;

import util = watt.toml.util;

import watt.io;
/*!
 * A TOML Value.
 *
 * `watt.toml` treats tables as a value, and thus represents the
 * entire document as a table.
 */
class Value
{
public:
	/*!
	 * Each TOML `Value` is typed with one of these types.
	 *
	 * The TOML spec also specifies a date type, but the watt TOML
	 * parser does not support and has no plans to support this
	 * type.
	 */
	enum Type
	{
		//! A series of characters.
		String,
		//! A 64 bit signed integer.
		Integer,
		//! A 64 bit floating point number.
		Float,
		//! A boolean value is `true` or `false`.
		Boolean,
		//! An array of `Value`s of the same type.
		Array,
		//! A table of `Value`s, indexed by string.
		Table
	}

public:
	//! The type of this `Value`.
	type: Type;
	//! Any comments that appeared before this value.
	comment: string;
	//! If this is a table, was it inline? (Affects `toString` functions).
	inline: bool;

public:
	//! Construct a `Value` with no type.
	this()
	{
	}

	//! Construct a `Value` with a string type.
	this(v: string)
	{
		type = Type.String;
		str(v);
	}

	//! Construct a `Value` with an integer type.
	this(v: i64)
	{
		type = Type.Integer;
		integer(v);
	}

	//! Construct a `Value` with an integer type.
	this(v: i32)
	{
		// This constructor worksarond an integer promotion bug, !!!
		type = Type.Integer;
		integer(v);
	}

	//! Construct a `Value` with a floating point type.
	this(v: f64)
	{
		type = Type.Float;
		floating(v);
	}

	//! Construct a `Value` with a boolean type.
	this(v: bool)
	{
		type = Type.Boolean;
		boolean(v);
	}

	/*!
	 * Construct an array of `Value`s.
	 *
	 * @Throws `TomlException` if any of the given `Value`s do not have the same type.
	 */
	this(v: Value[])
	{
		type = Type.Array;
		array(v);
	}

	/*!
	 * Get the keys for this table.
	 *
	 * Corresponds to the array returned by `tableValues`.
	 *
	 * @Throws `TomlException` if this `Value` is not a table.
	 */
	fn tableKeys() string[]
	{
		enforce(Type.Table);
		return mUnion.table.keys();
	}

	/*!
	 * Get the Values set for this table.
	 *
	 * Corresponds to the array return by `tableKeys`.
	 *
	 * @Throws `TomlException` if this `Value` is not a table.
	 */
	fn tableValues() Value[]
	{
		enforce(Type.Table);
		return mUnion.table.values();
	}

	/*!
	 * If this is a table, remove the given key, if it is set.
	 *
	 * No operation is performed if the key is not set.
	 *
	 * @Throws `TomlException` if this `Value` is not a table.
	 */
	fn removeKey(key: string)
	{
		enforce(Type.Table);
		if (!hasKey(key)) {
			return;
		}
		mUnion.table.remove(key);
	}

	/*!
	 * Get a string representation of the value.
	 *
	 * The string returned will be a valid TOML document.
	 */
	override fn toString() string
	{
		ss: sink.StringSink;
		toString(ss.sink);
		return ss.toString();
	}

	/*!
	 * Add the string representation of this `Value` to the given sink.
	 *
	 * The `parent` parameter is for setting what table a sub table belongs to,
	 * and in most user code should be left blank.
	 */
	fn toString(sink: sink.Sink, parent: string = "")
	{
		final switch (type) with (Value.Type) {
		case String:
			sink(new "\"${mUnion.str}\"");
			break;
		case Integer:
			sink(new "${mUnion.integer}");
			break;
		case Float:
			sink(new "${mUnion.floating}");
			break;
		case Boolean:
			sink(new "${mUnion.boolean}");
			break;
		case Array:
			sink("[");
			foreach (i, v; mUnion.array) {
				sink(v.toString());
				if (i < mUnion.array.length - 1) {
					sink(", ");
				}
			}
			sink("]");
			break;
		case Table:
			keys := mUnion.table.keys;
			values := mUnion.table.values;
			assert(keys.length == values.length);
			fn cmp(a: size_t, b: size_t) bool
			{
				pa := keys[a] in mKeyOrder;
				pb := keys[b] in mKeyOrder;
				if (pa !is null && pb !is null) {
					return *pa < *pb;
				}
				if (values[a].type == Value.Type.Table) {
					return false;
				}
				if (values[a].type == Value.Type.Array) {
					return values[b].type == Value.Type.Table;
				}
				return true;
			}
			fn swap(a: size_t, b: size_t)
			{
				ktmp := keys[a];
				vtmp := values[a];
				keys[a] = keys[b];
				values[a] = values[b];
				keys[b] = ktmp;
				values[b] = vtmp;
			}
			algo.runSort(keys.length, cmp, swap);

			firstNonTable := true;
			if (inline) {
				sink("{");
			}
			foreach (i, k; keys) {
				v := values[i];
				lines := text.splitLines(v.comment);
				foreach (j, line; lines) {
					if (j == lines.length - 1 && line == "") {
						continue;
					}
					sink(new "#${line}\n");
				}
				if (v.type != Value.Type.Table) {
					if (v.type == Value.Type.Array && v.array().length > 0
						&& v.array()[0].type == Value.Type.Table && !v.array()[0].inline) {
						foreach (e; v.array()) {
							parent2 := parent ~ quoteIfNeeded(k);
							sink("[[");
							sink(parent2);
							sink("]]\n");
							e.toString(sink, parent2 ~ ".");
						}
					} else {
						if (inline && !firstNonTable) {
							sink(", ");
						}
						sink(new "${quoteIfNeeded(k)} = ${v}");
						if (!inline) {
							sink("\n");
						}
					}
					firstNonTable = false;
				} else {
					if (v.inline) {
						// point = { x = 2 }
						sink(new "${quoteIfNeeded(v.mInlineName)} = ");
						v.toString(sink, parent ~ quoteIfNeeded(k) ~ ".");
						sink("\n");
					} else {
						// [point]
						// x = 2
						sink("[");
						parent2 := parent ~ quoteIfNeeded(k);
						sink(parent2);
						sink("]\n");
						v.toString(sink, parent2 ~ ".");
					}
				}
			}
			if (inline) {
				sink("}");
			}
			break;
		}
	}

	/*!
	 * Retrieve the string value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a string.
	 */
	fn str() string
	{
		enforce(Type.String);
		return mUnion.str;
	}

	/*!
	 * Set the string value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a string.
	 */
	fn str(val: string)
	{
		enforce(Type.String);
		mUnion.str = val;
	}

	/*!
	 * Retrieve the integer value.
	 *
	 * @Throws `TomlException` if this `Value` isn't an integer.
	 */
	fn integer() i64
	{
		enforce(Type.Integer);
		return mUnion.integer;
	}

	/*
	 * Set the integer value.
	 *
	 * @Throws `TomlException` if this `Value` isn't an integer.
	 */
	fn integer(val: i64)
	{
		enforce(Type.Integer);
		mUnion.integer = val;
	}

	/*!
	 * Retrieve the floating value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a float.
	 */
	fn floating() f64
	{
		enforce(Type.Float);
		return mUnion.floating;
	}

	/*!
	 * Set the floating value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a float.
	 */
	fn floating(val: f64)
	{
		enforce(Type.Float);
		mUnion.floating = val;
	}

	/*!
	 * Retrieve the boolean value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a boolean.
	 */
	fn boolean() bool
	{
		enforce(Type.Boolean);
		return mUnion.boolean;
	}

	/*!
	 * Set the boolean value.
	 *
	 * @Throws `TomlException` if this `Value` isn't a boolean.
	 */
	fn boolean(val: bool)
	{
		enforce(Type.Boolean);
		mUnion.boolean = val;
	}

	/*!
	 * Retrieve the array value.
	 *
	 * @Throws `TomlException` if this `Value` isn't an array.
	 */
	fn array() Value[]
	{
		enforce(Type.Array);
		return mUnion.array;
	}

	/*!
	 * Set a table entry.
	 *
	 * @Throws `TomlException` if this `Value` isn't an array.
	 */
	fn tableEntry(k: string, v: Value)
	{
		enforce(Type.Table);
		mUnion.table[k] = v;
	}

	/*!
	 * Set the array value.
	 *
	 * @Throws `TomlException` if this `Value` isn't an array,
	 * or if the array is mistyped.
	 */
	fn array(vals: Value[])
	{
		lastVal: Value;
		foreach (val; vals) {
			if (lastVal is null) {
				lastVal = val;
				continue;
			}
			if (lastVal.type != val.type) {
				throw new util.TomlException("all Values in an array must be of the same type");
			}
		}
		mUnion.array = new vals[0 .. $];
	}

	/*!
	 * How many keys does this table have set?
	 *
	 * @Returns The number of keys that have been set.
	 * @Throw `TomlExeption` if this `Value` isn't a table.
	 */
	fn countKeys() size_t
	{
		enforce(Type.Table);
		return mUnion.table.length;
	}

	/*!
	 * Does this table have a key?
	 *
	 * @Returns `true` if the key is set.
	 * @Throw `TomlException` if this `Value` isn't a table.
	 */
	fn hasKey(key: string) bool
	{
		enforce(Type.Table);
		return (key in mUnion.table) !is null;
	}

	/*!
	 * Retrieve a key from this table.
	 *
	 * @Throw `TomlException` if the key isn't set, or this isn't a table.
	 */
	fn opIndex(key: string) Value
	{
		enforce(Type.Table);
		ptr := key in mUnion.table;
		if (ptr is null) {
			throw new util.TomlException(new "key \"${key}\" not set.");
		}
		return *ptr;
	}

private:
	// This *should* be a union, but that triggers a bug on Windows.  <https://trello.com/c/n9ExzPU0/334-union-aas-windows>
	union ValueUnion
	{
		str: string;
		integer: i64;
		floating: f64;
		boolean: bool;
		array: Value[];
		table: Value[string];
	}

private:
	fn quoteIfNeeded(str: string) string
	{
		foreach (c: char; str) {
			if (ascii.isWhite(c)) {
				return "\"" ~ str ~ "\"";
			}
		}
		return str;
	}

private:
	mUnion: ValueUnion;
	mTableArray: bool;
	mBeenAtHead: bool;   // [a.b.c] == [false.false.true]
	mKeyOrder: size_t[string];
	mInlineName: string;

private:
	// Ensure that this value is the given type, or throw otherwise.
	fn enforce(type: Type)
	{
		if (this.type != type) {
			throw new util.TomlException(new "Value is a ${this.type}, not a ${type}.");
		}
	}
}

/*!
 * Given a TOML document, return a `Value` that represents that document.
 *
 * The returned `Value` will be a table.
 */
fn parse(src: string) Value
{
	tparser := new TreeParser();
	event.runEventSink(src, tparser);
	assert(tparser.result !is null);
	return tparser.result;
}

private:

fn splitTableName(name: string) string[]
{
	src: source.SimpleSource;
	src.source = name;

	lastNonWhitespace: dchar;
	names: string[];
	currentMark := src.save();
	while (!src.eof) {
		if (!ascii.isWhite(src.front)) {
			lastNonWhitespace = src.front;
		}
		if (src.front == '.') {
			str := text.strip(src.sliceFrom(currentMark));
			if (str.length == 0) {
				throw new util.TomlException("Empty table name.");
			}
			names ~= str;
			src.popFront();
			currentMark = src.save();
			continue;
		} else if (src.front == '"' || src.front == '\'') {
			str := util.parseString(ref src);
			if (str.length == 0) {
				throw new util.TomlException("Empty table name.");
			}
			if (!src.eof && src.front != '.') {
				throw new util.TomlException("Expected '.' after string component of table name.");
			}
			names ~= str;
			src.popFront();
			currentMark = src.save();
			continue;
		} else {
			src.popFront();
		}
	}
	if (lastNonWhitespace == '.') {
		throw new util.TomlException("Empty table name.");
	}
	str := text.strip(src.sliceFrom(currentMark));
	if (str.length > 0) {
		names ~= str;
	}
	if (names.length == 0) {
		throw new util.TomlException("Empty table name.");
	}
	return names;
}

class TreeParser : event.NullEventSink
{
public:
	struct Inline
	{
		isArray: bool;
		keyName: string;
		val: Value;
		arr: Value[];
	}

public:
	result: Value;

	currentKey: string;
	tableArrayTable: Value;
	commentSink: sink.StringSink;

	tableStack: Value[];
	inlineStack: Inline[];

	override fn start()
	{
		result = new Value();
		result.type = Value.Type.Table;
		tableStack ~= result;
	}

	override fn tableStart(name: string)
	{
		tableArrayTable = null;
		names := splitTableName(name);
		foreach (i, tname; names) {
			if (p := tname in tableStack[$-1].mUnion.table) {
				if (p.mTableArray && i < names.length - 1) {
					tableStack ~= p.mUnion.array[$-1];
					continue;
				}
				if ((i == names.length - 1 && p.mBeenAtHead) || p.type != Value.Type.Table) {
					throw new util.TomlException(new "Redefining ${tname}.");
				}
				tableStack ~= *p;
				continue;
			}
			table := new Value();
			table.type = Value.Type.Table;
			tableStack[$-1].mUnion.table[tname] = table;
			tableStack[$-1].mKeyOrder[tname] = tableStack[$-1].mKeyOrder.length;
			tableStack ~= table;
		}
		tableStack[$-1].comment = commentSink.toString();
		commentSink.reset();
		tableStack[$-1].mBeenAtHead = true;
	}

	override fn tableEnd(name: string)
	{
		assert(tableStack.length > 1);
		names := splitTableName(name);
		foreach (tname; names) {
			tableStack = tableStack[0 .. $-1];
		}
	}

	override fn inlineTableStart()
	{
		inlineTable: Inline;
		inlineTable.val = new Value();
		inlineTable.val.type = Value.Type.Table;
		inlineTable.val.inline = true;
		inlineTable.val.mInlineName = currentKey;
		inlineTable.keyName = currentKey;
		inlineStack ~= inlineTable;
	}

	override fn inlineTableEnd()
	{
		assert(inlineStack.length > 0);
		table := inlineStack[$-1];
		inlineStack = inlineStack[0 .. $-1];
		currentKey = table.keyName;
		addValue(table.val);
	}

	override fn tableArray(name: string)
	{
		names := splitTableName(name);
		lastTable := result;
		foreach (prename; names[0 .. $-1]) {
			p := prename in lastTable.mUnion.table;
			if (p := prename in lastTable.mUnion.table) {
				if (p.mTableArray) {
					lastTable = p.mUnion.array[$-1];
					continue;
				}
				if (p.type != Value.Type.Table || p.mUnion.table.length > 1) {
					throw new util.TomlException(new "Redefining ${prename}.");
				}
				foreach (key; p.mUnion.table.keys) {
					if (p.mUnion.table[key].type != Value.Type.Table) {
						throw new util.TomlException(new "Redefining table ${prename}.");
					}
				}
				lastTable = *p;
				continue;
			}
			table := new Value();
			table.type = Value.Type.Table;
			lastTable.mUnion.table[prename] = table;
			lastTable = table;
		}

		aname := names[$-1];
		array: Value;
		if (p := aname in lastTable.mUnion.table) {
			if (!p.mTableArray) {
				throw new util.TomlException(new "Redefining array of tables ${aname}");
			}
			array = *p;
		} else {
			array = new Value();
			array.type = Value.Type.Array;
			array.mTableArray = true;
			lastTable.mUnion.table[aname] = array;
			lastTable.mKeyOrder[aname] = lastTable.mKeyOrder.length;
		}

		array.comment = commentSink.toString();
		commentSink.reset();

		tableArrayTable = new Value();
		tableArrayTable.type = Value.Type.Table;
		array.mUnion.array ~= tableArrayTable;
	}

	override fn arrayStart()
	{
		empty: Inline;
		empty.isArray = true;
		inlineStack ~= empty;
	}

	override fn arrayEnd()
	{
		assert(inlineStack.length > 0 && inlineStack[$-1].isArray);
		arr := inlineStack[$-1].arr;
		inlineStack = inlineStack[0 .. $-1];
		addValue(new Value(arr));
	}

	override fn commentStart()
	{
		mInComment = true;
	}

	override fn commentEnd()
	{
		mInComment = false;
	}

	override fn keyValueStart(key: string)
	{
		currentKey = key;
	}

	override fn stringContent(v: string)
	{
		if (mInComment) {
			commentSink.sink(v);
			commentSink.sink("\n");
			return;
		}
		addValue(new Value(v));
	}

	override fn integerContent(v: i64)
	{
		addValue(new Value(v));
	}

	override fn boolContent(v: bool)
	{
		addValue(new Value(v));
	}

	override fn floatContent(v: f64)
	{
		addValue(new Value(v));
	}

	fn addValue(val: Value)
	{
		val.comment = commentSink.toString();
		commentSink.reset();
		if (inlineStack.length > 0) {
			if (!inlineStack[$-1].isArray) {
				inlineStack[$-1].val.mUnion.table[currentKey] = val;
				inlineStack[$-1].val.mKeyOrder[currentKey] = inlineStack[$-1].val.mKeyOrder.length;
			} else {
				if (inlineStack[$-1].arr.length > 0 && val.type != inlineStack[$-1].arr[$-1].type) {
					throw new util.TomlException("Array elements must all be of the same type.");
				}
				inlineStack[$-1].arr ~= val;
			}
		} else if (tableArrayTable !is null) {
			tableArrayTable.mUnion.table[currentKey] = val;
			tableArrayTable.mKeyOrder[currentKey] = tableArrayTable.mKeyOrder.length;
		} else {
			tableStack[$-1].mUnion.table[currentKey] = val;
			tableStack[$-1].mKeyOrder[currentKey] = tableStack[$-1].mKeyOrder.length;
		}
	}

private:
	mInComment: bool;
}
