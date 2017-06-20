// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, David Herberth.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Parse a JSON file into memory.
module watt.text.json.dom;

import watt.text.format;
import watt.text.json.util;
import watt.text.json.sax;

//! Thrown upon a parsing error.
class DOMException : JSONException
{
	this(msg: string, location: string = __LOCATION__)
	{
		super(msg, location);
	}
}

enum DomType
{
	NULL,
	BOOLEAN,
	DOUBLE,
	LONG,
	ULONG,
	STRING,
	OBJECT,
	ARRAY
}

private fn enforceJEx(b: bool, msg: string = "Json type enforce failure.",
                      location: string = __LOCATION__)
{
	if (!b) {
		throw new DOMException(msg, location);
	}
}

/*!
 * Represents a JSON value.
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
	 * Returns the DomType of the value stored in this node.
	 */
	fn type() DomType
	{
		return _type;
	}

	/*!
	 * Test whether the type is null.
	 */
	fn isNull() bool
	{
		return _type == DomType.NULL;
	}

	/*!
	 * Set the type to null.
	 */
	fn setNull()
	{
		_type = DomType.NULL;
	}

	/*!
	 * Getter for DomType.BOOLEAN.
	 */
	fn boolean() bool
	{
		enforceJEx(_type == DomType.BOOLEAN, "Value is not a boolean.");
		return store.boolean;
	}

	/*!
	 * Setter for DomType.BOOLEAN.
	 */
	fn boolean(b: bool)
	{
		_type = DomType.BOOLEAN;
		store.boolean = b;
	}

	/*!
	 * Getter for DomType.STRING.
	 */
	fn str() string
	{
		enforceJEx(_type == DomType.STRING, "Value is not a string.");
		return store.str;
	}

	/*!
	 * Setter for DomType.STRING.
	 */
	fn str(s: string)
	{
		_type = DomType.STRING;
		store.str = s;
	}

	/*!
	 * Getter for DomType.LONG.
	 */
	fn integer() i64
	{
		enforceJEx(_type == DomType.LONG, "Value is not a long.");
		return store.integer;
	}

	/*!
	 * Setter for DomType.LONG.
	 */
	fn integer(l: i64)
	{
		_type = DomType.LONG;
		store.integer = l;
	}

	/*!
	 * Getter for DomType.ULONG.
	 */
	fn unsigned() u64
	{
		enforceJEx(_type == DomType.ULONG, "Value is not a ulong.");
		return store.unsigned;
	}

	/*!
	 * Setter for DomType.ULONG.
	 */
	fn unsigned(l: u64)
	{
		_type = DomType.ULONG;
		store.unsigned = l;
	}

	/*!
	 * Getter for DomType.DOUBLE.
	 */
	fn floating() f64
	{
		enforceJEx(_type == DomType.DOUBLE, "Value is not a double.");
		return store.floating;
	}

	/*!
	 * Setter for DomType.DOUBLE.
	 */
	fn floating(d: f64)
	{
		_type = DomType.DOUBLE;
		store.floating = d;
	}

	/*!
	 * Getter for DomType.ARRAY.
	 */
	fn array() Value[]
	{
		enforceJEx(_type == DomType.ARRAY, "Value is not an array.");
		return _array;
	}

	/*!
	 * Setter for DomType.ARRAY.
	 */
	fn array(array: Value[])
	{
		_type = DomType.ARRAY;
		_array = array;
	}

	/*!
	 * Add value to the array.
	 */
	fn arrayAdd(val: Value)
	{
		enforceJEx(_type == DomType.ARRAY, "Value is not an array.");
		_array ~= val;
	}

	/*!
	 * Set type as DomType.ARRAY.
	 */
	fn setArray()
	{
		_type = DomType.ARRAY;
	}

	/*!
	 * Getter for DomType.OBJECT.
	 */
	fn lookupObjectKey(s: string) Value
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		p := s in object;
		if (p is null) {
			throw new DOMException(format("Lookup of '%s' through JSON object failed.", s));
		}
		return *p;
	}

	/*!
	 * Determines if this is an object with the given key.
	 */
	fn hasObjectKey(s: string) bool
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		return (s in object) !is null;
	}

	/*!
	 * Setter for DomType.OBJECT.
	 */
	fn setObjectKey(s: string, v: Value)
	{
		_type = DomType.OBJECT;
		object[s] = v;
	}

	/*!
	 * Set type as DomType.OBJECT.
	 */
	fn setObject()
	{
		_type = DomType.OBJECT;
	}

	/*!
	 * If this is an object, retrieves the keys it has.
	 */
	fn keys() string[]
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		return object.keys;
	}

	/*!
	 * If this is an object, retrieves the values it has.
	 */
	fn values() Value[]
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		return object.values;
	}
}

private enum LONG_MAX = 9223372036854775807UL;

//! Parse a JSON string.
fn parse(s: string) Value
{
	val: Value;
	val.setObject();
	valueStack: Value[];
	keyStack: string[];

	fn addKey(key: string)
	{
		keyStack ~= key;
	}

	fn getKey() string
	{
		assert(valueStack.length >= 1);
		if (valueStack[$-1]._type == DomType.ARRAY) {
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
		assert(valueStack[$-1]._type == DomType.OBJECT || valueStack[$-1]._type == DomType.ARRAY);
		if (valueStack[$-1]._type == DomType.OBJECT) {
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
				parseLong(cast(const(char[]))data, out l);
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

