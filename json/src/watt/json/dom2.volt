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


//! Identifies the JSON type of a `Value`.
enum Type
{
	//! Not a valid object.
	NOTHING,
	//! A JSON value of `null`.
	NULL,
	//! A JSON value of `true` or `false`.
	BOOLEAN,
	//! A JSON value of a number with a decimal portion.
	DOUBLE,
	//! A JSON value of a signed integer.
	LONG,
	//! A JSON value of an unsigned integer.
	ULONG,
	//! A JSON string.
	STRING,
	//! A JSON object, everything between {}.
	OBJECT,
	//! A JSON array, everything between \[\].
	ARRAY
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

	fn isSomething() bool { return type != Type.NOTHING; }
	fn isNothing() bool { return type == Type.NOTHING; }
	fn isNull() bool { return type == Type.NULL; }
	fn isBool() bool { return type == Type.BOOLEAN; }
	fn isDouble() bool { return type == Type.DOUBLE; }
	fn isLong() bool { return type == Type.LONG; }
	fn isUlong() bool { return type == Type.ULONG; }
	fn isString() bool { return type == Type.STRING; }
	fn isObject() bool { return type == Type.OBJECT; }
	fn isArray() bool { return type == Type.ARRAY; }


	/*
	 *
	 * get functions.
	 *
	 */

	fn getBool(out ret: bool) bool
	{
		if (type != Type.BOOLEAN) {
			return false;
		}

		ret = store.boolean;
		return true;
	}

	fn getDouble(out ret: f64) bool
	{
		if (type != Type.DOUBLE) {
			return false;
		}

		ret = store.floating;
		return true;
	}

	fn getLong(out ret: i64) bool
	{
		if (type != Type.LONG) {
			return false;
		}

		ret = store.integer;
		return true;
	}

	fn getUlong(out ret: u64) bool
	{
		if (type != Type.ULONG) {
			return false;
		}

		ret = store.unsigned;
		return true;
	}

	fn getString(out ret: string) bool
	{
		if (type != Type.STRING) {
			return false;
		}

		ret = store.str;
		return true;
	}

	fn getArray(out ret: Value[]) bool
	{
		if (type != Type.ARRAY) {
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
		Value tmp;
		if (type != Type.OBJECT) {
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
		if (type != Type.OBJECT) {
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
		Value tmp;
		if (type != Type.ARRAY) {
			return tmp;
		}

		if (index >= store.array.length) {
			return tmp;
		}

		return store.array[index];
	}

	fn byIndex(index: size_t, out ret: Value) bool
	{
		if (type != Type.ARRAY) {
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
		if (type != Type.BOOLEAN) {
			return bool.init;
		}
		return store.boolean;
	}

	@property fn asDouble() f64
	{
		if (type != Type.DOUBLE) {
			return f64.init;
		}
		return store.floating;
	}

	@property fn asLong() i64
	{
		if (type != Type.LONG) {
			return i64.init;
		}
		return store.integer;
	}

	@property fn asUlong() u64
	{
		if (type != Type.ULONG) {
			return u64.init;
		}
		return store.unsigned;
	}

	@property fn asString() string
	{
		if (type != Type.STRING) {
			return null;
		}
		return store.str;
	}

	@property fn asArray() Value[]
	{
		if (type != Type.ARRAY) {
			return null;
		}
		return store.array;
	}
}