// Copyright 2015, Bernard Helyer.
// Copyright 2015, David Herberth.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Parse a [JSON](http://json.org/) file into memory.
 *
 * ### Example
 * ```volt
 * val: Value = parse("{}");
 * ```
 *
 * A DOM parser parses an entire file into memory at once.
 * This is often simpler, but if your files are very large,
 * you may need to use the SAX parser, see @ref watt.json.sax.
 */
module watt.json.dom2;

import watt.json.util;
import watt.json.sax;


//! Identifies the JSON type of a `Value`.
enum Type
{
	//! Not a valid object.
	Nothing,
	//! A JSON value of `null`.
	Null,
	//! A JSON value of `true` or `false`.
	Boolean,
	//! A JSON value of a number with a decimal portion.
	Double,
	//! A JSON value of a signed integer.
	Long,
	//! A JSON value of an unsigned integer.
	Ulong,
	//! A JSON string.
	String,
	//! A JSON object, everything between {}.
	Object,
	//! A JSON array, everything between \[\].
	Array
}

struct Value
{
private:
	union Store
	{
		boolean: bool;
		str: string;
		integer: i64;
		unsigned: u64;
		floating: f64;
		object: Value[string];
		array: Value[];
	}

	store: Store;
	type: Type;


public:
	/*
	 *
	 * is functions.
	 *
	 */

	fn isSomething() bool { return type != Type.Nothing; }
	fn isNothing() bool { return type == Type.Nothing; }
	fn isNull() bool { return type == Type.Null; }
	fn isBool() bool { return type == Type.Boolean; }
	fn isDouble() bool { return type == Type.Double; }
	fn isLong() bool { return type == Type.Long; }
	fn isUlong() bool { return type == Type.Ulong; }
	fn isString() bool { return type == Type.String; }
	fn isObject() bool { return type == Type.Object; }
	fn isArray() bool { return type == Type.Array; }


	/*
	 *
	 * get functions.
	 *
	 */

	fn getBool(out ret: bool) bool
	{
		if (type != Type.Boolean) {
			return false;
		}

		ret = store.boolean;
		return true;
	}

	fn getDouble(out ret: f64) bool
	{
		if (type != Type.Double && type != Type.Long && type != Type.Ulong) {
			return false;
		}

		switch (type) {
		case Type.Double:
			ret = store.floating;
			return true;
		case Type.Long:
			ret = cast(f64)store.integer;
			return true;
		case Type.Ulong:
			ret = cast(f64)store.unsigned;
			return true;
		default:
			return false;
		}
	}

	fn getLong(out ret: i64) bool
	{
		if (type != Type.Long) {
			return false;
		}

		ret = store.integer;
		return true;
	}

	fn getUlong(out ret: u64) bool
	{
		if (type != Type.Ulong) {
			return false;
		}

		ret = store.unsigned;
		return true;
	}

	fn getString(out ret: string) bool
	{
		if (type != Type.String) {
			return false;
		}

		ret = store.str;
		return true;
	}

	fn getArray(out ret: Value[]) bool
	{
		if (type != Type.Array) {
			return false;
		}

		ret = store.array;
		return true;
	}


	/*
	 *
	 * by functions.
	 *
	 */

	fn byKey(key: string) Value
	{
		tmp: Value;
		if (type != Type.Object) {
			return tmp;
		}

		v := key in store.object;
		if (v is null) {
			return tmp;
		}

		return *v;
	}

	fn byKey(key: string, out ret: Value) bool
	{
		if (type != Type.Object) {
			return false;
		}

		v := key in store.object;
		if (v is null) {
			return false;
		}

		ret = *v;
		return true;
	}

	fn byIndex(index: size_t) Value
	{
		tmp: Value;
		if (type != Type.Array) {
			return tmp;
		}

		if (index >= store.array.length) {
			return tmp;
		}

		return store.array[index];
	}

	fn byIndex(index: size_t, out ret: Value) bool
	{
		if (type != Type.Array) {
			return false;
		}

		if (index >= store.array.length) {
			return false;
		}

		ret = store.array[index];
		return true;
	}


	/*
	 *
	 * as functions.
	 *
	 */

	@property fn asBoolean() bool
	{
		if (type != Type.Boolean) {
			return bool.init;
		}
		return store.boolean;
	}

	@property fn asDouble() f64
	{
		ret: f64;
		if (!getDouble(out ret)) {
			return f64.init;
		}
		return ret;
	}

	@property fn asLong() i64
	{
		if (type != Type.Long) {
			return i64.init;
		}
		return store.integer;
	}

	@property fn asUlong() u64
	{
		if (type != Type.Ulong) {
			return u64.init;
		}
		return store.unsigned;
	}

	@property fn asString() string
	{
		if (type != Type.String) {
			return null;
		}
		return store.str;
	}

	@property fn asArray() Value[]
	{
		if (type != Type.Array) {
			return null;
		}
		return store.array;
	}
}

private enum LONG_MAX = 9223372036854775807UL;

//! Parse a JSON string into a `Value`.
fn parse(s: string) Value
{
	val: Value;
//	val.type = Type.Object;

	valueStack: Value[];
	keyStack: string[];

	fn addKey(key: const(char)[])
	{
		keyStack ~= cast(string)key;
	}

	fn getKey() string
	{
		assert(valueStack.length >= 1);
		if (valueStack[$-1].type == Type.Array) {
			return "";
		}
		assert(keyStack.length >= 1);
		key := keyStack[$-1];
		keyStack = keyStack[0 .. $-1];
		return key;
	}

	fn pushValue(p: Value)
	{
		valueStack ~= p;
	}

	fn popValue() Value
	{
		assert(valueStack.length > 1);
		val := valueStack[$-1];
		valueStack = valueStack[0 .. $-1];
		return val;
	}

	fn addValue(val: Value, key: string ="")
	{
		assert(valueStack.length >= 1);
		assert(valueStack[$-1].type == Type.Object || valueStack[$-1].type == Type.Array);
		if (valueStack[$-1].type == Type.Object) {
			assert(key.length > 0);
			valueStack[$-1].store.object[key] = val;
		} else {
			assert(key.length == 0);
			valueStack[$-1].store.array ~= val;
		}
	}

	current := &val;
	loop := true;
	error := false;
	fn dgt(event: Event, data: const(ubyte)[])
	{
		if (event == Event.ERROR) {
			error = true;
			return;
		}
		loop = event != Event.END;
		v: Value;
		final switch (event) {
		case Event.ERROR:
			assert(false);
		case Event.END:
		case Event.START:
			break;
		case Event.NULL:
			v.type = Type.Null;
			addValue(v, getKey());
			break;
		case Event.BOOLEAN:
			v.type = Type.Boolean;
			v.store.boolean = parseBool(cast(const(char)[])data);
			addValue(v, getKey());
			break;
		case Event.NUMBER:
			if (canBeInteger(cast(const(char)[])data, false)) {
				ul: u64;
				parseUlong(cast(const(char)[])data, out ul);
				if (ul < LONG_MAX) {
					assert(canBeInteger(cast(const(char)[])data, true));
					l: i64;
					parseLong(cast(const(char)[])data, out l);
					v.type = Type.Long;
					v.store.integer = l;
					addValue(v, getKey());
					break;
				}
				v.type = Type.Ulong;
				v.store.unsigned = ul;
				addValue(v, getKey());
				break;
			} else if (canBeInteger(cast(const(char)[])data, true)) {
				l: i64;
				parseLong(cast(const(char)[])data, out l);
				v.type = Type.Long;
				v.store.integer = l;
				addValue(v, getKey());
				break;
			}
			d: f64;
			buf: char[];
			ret: bool = parseDouble(cast(const(char)[])data, out d, ref buf);
			assert(ret);
			v.type = Type.Double;
			v.store.floating = d;
			addValue(v, getKey());
			break;
		case Event.STRING:
			v.type = Type.String;
			v.store.str = cast(string)unescapeString(data);
			addValue(v, getKey());
			break;
		case Event.ARRAY_START:
			v.type = Type.Array;
			pushValue(v);
			break;
		case Event.ARRAY_END:
			if (valueStack.length > 1) {
				av := popValue();
				addValue(av, getKey());
			}
			break;
		case Event.OBJECT_START:
			v.type = Type.Object;
			pushValue(v);
			break;
		case Event.OBJECT_END:
			if (valueStack.length > 1) {
				ov := popValue();
				addValue(ov, getKey());
			}
			break;
		case Event.OBJECT_KEY:
			addKey(unescapeString(data));
			break;
		}
	}
	sax := new SAX(s);
	invalid: Value;
	while (loop) {
		sax.get(dgt);
		if (error) {
			return invalid;
		}
	}
	assert(valueStack.length == 1);
	return valueStack[$-1];
}
