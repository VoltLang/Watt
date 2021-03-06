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
module watt.json.dom;

import watt.json.util;
import watt.json.sax;

//! Thrown upon a parsing error.
class DOMException : JSONException
{
	this(msg: string, location: string = __LOCATION__)
	{
		super(msg, location);
	}
}

//! Identifies the JSON type of a `Value`.
enum DomType
{
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

private fn enforceJEx(b: bool, msg: string = "Json type enforce failure.",
                      location: string = __LOCATION__)
{
	if (!b) {
		throw new DOMException(msg, location);
	}
}

/*!
 * A JSON value.
 */
struct Value
{
	union Store
	{
		boolean: bool;
		str: immutable(char)[];  // TODO: If this is a string, Volt's classify blows up.
		integer: i64;
		unsigned: u64;
		floating: f64;
	}
	private store: Store;
	private _type: DomType;
	private _array: Value[];
	private object: Value[string];

	/*!
	 * @Returns The `DomType` of the value stored in this node.
	 */
	fn type() DomType
	{
		return _type;
	}

	/*!
	 * Is this `Value` a JSON null type?
	 * @Returns `true` if this is a null.
	 */
	fn isNull() bool
	{
		return _type == DomType.Null;
	}

	/*!
	 * Set the type to null.
	 */
	fn setNull()
	{
		_type = DomType.Null;
	}

	/*!
	 * Get this as a boolean value.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Boolean`.
	 */
	fn boolean() bool
	{
		enforceJEx(_type == DomType.Boolean, "Value is not a boolean.");
		return store.boolean;
	}

	/*!
	 * Set this `Value` as a `DomType.Boolean`, and give it the value `b`.
	 */
	fn boolean(b: bool)
	{
		_type = DomType.Boolean;
		store.boolean = b;
	}

	/*!
	 * Get this as a string value.
	 * @Throws `DOMException` if this `Value` is not a `DomType.String`.
	 */
	fn str() string
	{
		enforceJEx(_type == DomType.String, "Value is not a string.");
		return store.str;
	}

	/*!
	 * Set this `Value` as a `DomType.String`, and give it the value `s`.
	 */
	fn str(s: const(char)[])
	{
		_type = DomType.String;
		store.str = cast(string)s;
	}

	/*!
	 * Get this as an integer value.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Long`.
	 */
	fn integer() i64
	{
		enforceJEx(_type == DomType.Long, "Value is not a long.");
		return store.integer;
	}

	/*!
	 * Set this `Value` as a `DomType.Long`, and give it the value `l`.
	 */
	fn integer(l: i64)
	{
		_type = DomType.Long;
		store.integer = l;
	}

	/*!
	 * Get this as an unsigned integer value.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Ulong`.
	 */
	fn unsigned() u64
	{
		enforceJEx(_type == DomType.Ulong, "Value is not a ulong.");
		return store.unsigned;
	}

	/*!
	 * Set this `Value` as a `DomType.Ulong`, and give it the value `l`.
	 */
	fn unsigned(l: u64)
	{
		_type = DomType.Ulong;
		store.unsigned = l;
	}

	/*!
	 * Get this as a floating point value.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Double`.
	 */
	fn floating() f64
	{
		enforceJEx(_type == DomType.Double, "Value is not a double.");
		return store.floating;
	}

	/*!
	 * Set this `Value` as a `DomType.Double`, and give it the value `d`.
	 */
	fn floating(d: f64)
	{
		_type = DomType.Double;
		store.floating = d;
	}

	/*!
	 * Get this as an array of `Value`.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Array`.
	 */
	fn array() Value[]
	{
		enforceJEx(_type == DomType.Array, "Value is not an array.");
		return _array;
	}

	/*!
	 * Set this `Value` as a `DomType.Array`, and give it the value `array`.
	 */
	fn array(array: Value[])
	{
		_type = DomType.Array;
		_array = array;
	}

	/*!
	 * Add `val` to this `Value`'s array.
	 * @Throws `DOMException` if this is not a `DomType.Array`.
	 */
	fn arrayAdd(val: Value)
	{
		enforceJEx(_type == DomType.Array, "Value is not an array.");
		_array ~= val;
	}

	/*!
	 * Set type as `DomType.Array`.
	 */
	fn setArray()
	{
		_type = DomType.Array;
	}

	/*!
	 * Retrieve a key from this `Value`.
	 * @Throws `DOMException` if the lookup fails, or if this `Value` is not a
	 * `DomType.Object`.
	 */
	fn lookupObjectKey(s: string) Value
	{
		enforceJEx(_type == DomType.Object, "Value is not an object.");
		p := s in object;
		if (p is null) {
			throw new DOMException(new "Lookup of '${s}' through JSON object failed.");
		}
		return *p;
	}

	/*!
	 * Does this object have a key `s`?
	 * @Returns `true` if this `Value` has the given key.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Object`.
	 */
	fn hasObjectKey(s: string) bool
	{
		enforceJEx(_type == DomType.Object, "Value is not an object.");
		return (s in object) !is null;
	}

	/*!
	 * Set this `Value` as an object, and set a key.
	 * @Param k The key to set.
	 * @Param v The value to associate with `k`.
	 */
	fn setObjectKey(k: string, v: Value)
	{
		_type = DomType.Object;
		object[k] = v;
	}

	/*!
	 * Set type as `DomType.Object`.
	 */
	fn setObject()
	{
		_type = DomType.Object;
	}

	/*!
	 * Retrieve all the keys associated with this `Value`.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Object`.
	 */
	fn keys() string[]
	{
		enforceJEx(_type == DomType.Object, "Value is not an object.");
		return object.keys;
	}

	/*!
	 * Retrieve all the values associated with this `Value`.
	 * @Throws `DOMException` if this `Value` is not a `DomType.Object`.
	 */
	fn values() Value[]
	{
		enforceJEx(_type == DomType.Object, "Value is not an object.");
		return object.values;
	}
}

private enum LONG_MAX = 9223372036854775807UL;

//! Parse a JSON string into a `Value`.
fn parse(s: string) Value
{
	val: Value;
	val.setObject();
	valueStack: Value[];
	keyStack: string[];

	fn addKey(key: const(char)[])
	{
		keyStack ~= cast(string)key;
	}

	fn getKey() string
	{
		assert(valueStack.length >= 1);
		if (valueStack[$-1]._type == DomType.Array) {
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
		assert(valueStack[$-1]._type == DomType.Object || valueStack[$-1]._type == DomType.Array);
		if (valueStack[$-1]._type == DomType.Object) {
			assert(key.length > 0);
			valueStack[$-1].setObjectKey(key, val);
		} else {
			assert(key.length == 0);
			valueStack[$-1].arrayAdd(val);
		}
	}

	current := &val;
	loop := true;
	fn dgt(event: Event, data: const(ubyte)[])
	{
		if (event == Event.ERROR) {
			throw new DOMException(cast(string)data);
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
			v.setNull();
			addValue(v, getKey());
			break;
		case Event.BOOLEAN:
			v.boolean(parseBool(cast(const(char)[])data));
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
					v.integer(l);
					addValue(v, getKey());
					break;
				}
				v.unsigned(ul);
				addValue(v, getKey());
				break;
			} else if (canBeInteger(cast(const(char)[])data, true)) {
				l: i64;
				parseLong(cast(const(char)[])data, out l);
				v.integer(l);
				addValue(v, getKey());
				break;
			}
			d: f64;
			buf: char[];
			ret: bool = parseDouble(cast(const(char)[])data, out d, ref buf);
			assert(ret);
			v.floating(d);
			addValue(v, getKey());
			break;
		case Event.STRING:
			v.str(unescapeString(data));
			addValue(v, getKey());
			break;
		case Event.ARRAY_START:
			v.setArray();
			pushValue(v);
			break;
		case Event.ARRAY_END:
			if (valueStack.length > 1) {
				av := popValue();
				addValue(av, getKey());
			}
			break;
		case Event.OBJECT_START:
			v.setObject();
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
	while (loop) {
		sax.get(dgt);
	}
	assert(valueStack.length == 1);
	return valueStack[$-1];
}

