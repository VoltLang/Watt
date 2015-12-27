// Copyright © 2015, Bernard Helyer.  All rights reserved.
// Copyright © 2015, David Herberth.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.json.dom;

import watt.io;
import watt.text.format;
import watt.text.json.util;
import watt.text.json.sax;
import watt.io.streams : InputStream, OutputStream, OutputStringBufferStream;

class DOMException : JSONException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
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

private void enforceJEx(bool b, string msg = "Json type enforce failure.",
                        string file = __FILE__, size_t line = __LINE__)
{
	if (!b) {
		throw new DOMException(msg, file, line);
	}
}

/**
 * Represents a JSON value.
 */
struct Value
{
	union Store
	{
		bool boolean;
		immutable(char)[] str;  // TODO: If this is a string, Volt's classify blows up.
		long integer;
		ulong unsigned;
		double floating;
	}
	private Store store;
	/*private*/ DomType _type;
	private Value[] _array;
	private Value[string] object;

	/**
	 * Returns the DomType of the value stored in this node.
	 */
	DomType type()
	{
		return _type;
	}

	/**
	 * Test wether the type is null.
	 */
	bool isNull()
	{
		return _type == DomType.NULL;
	}

	/**
	 * Set the type to null.
	 */
	void setNull()
	{
		_type = DomType.NULL;
	}

	/**
	 * Getter for DomType.BOOLEAN.
	 */
	bool boolean()
	{
		enforceJEx(_type == DomType.BOOLEAN, "Value is not a boolean.");
		return store.boolean;
	}

	/**
	 * Setter for DomType.BOOLEAN.
	 */
	void boolean(bool b)
	{
		_type = DomType.BOOLEAN;
		store.boolean = b;
	}

	/**
	 * Getter for DomType.STRING.
	 */
	string str()
	{
		enforceJEx(_type == DomType.STRING, "Value is not a string.");
		return store.str;
	}

	/**
	 * Setter for DomType.STRING.
	 */
	void str(string s)
	{
		_type = DomType.STRING;
		store.str = s;
	}

	/**
	 * Getter for DomType.LONG.
	 */
	long integer()
	{
		enforceJEx(_type == DomType.LONG, "Value is not a long.");
		return store.integer;
	}

	/**
	 * Setter for DomType.LONG.
	 */
	void integer(long l)
	{
		_type = DomType.LONG;
		store.integer = l;
	}

	/**
	 * Getter for DomType.ULONG.
	 */
	ulong unsigned()
	{
		enforceJEx(_type == DomType.ULONG, "Value is not a ulong.");
		return store.unsigned;
	}

	/**
	 * Setter for DomType.ULONG.
	 */
	void unsigned(ulong l)
	{
		_type = DomType.ULONG;
		store.unsigned = l;
	}

	/**
	 * Getter for DomType.DOUBLE.
	 */
	double floating()
	{
		enforceJEx(_type == DomType.DOUBLE, "Value is not a double.");
		return store.floating;
	}

	/**
	 * Setter for DomType.DOUBLE.
	 */
	void floating(double d)
	{
		_type = DomType.DOUBLE;
		store.floating = d;
	}

	/**
	 * Getter for DomType.ARRAY.
	 */
	Value[] array()
	{
		enforceJEx(_type == DomType.ARRAY, "Value is not an array.");
		return _array;
	}

	/**
	 * Setter for DomType.ARRAY.
	 */
	void array(Value[] array)
	{
		_type = DomType.ARRAY;
		_array = array;
	}

	/**
	 * Add value to the array.
	 */
	void arrayAdd(Value val)
	{
		enforceJEx(_type == DomType.ARRAY, "Value is not an array.");
		_array ~= val;
	}

	/**
	 * Set type as DomType.ARRAY.
	 */
	void setArray()
	{
		_type = DomType.ARRAY;
	}

	/**
	 * Getter for DomType.OBJECT.
	 */
	Value lookupObjectKey(string s)
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		auto p = s in object;
		if (p is null) {
			throw new DOMException(format("Lookup of '%s' through JSON object failed.", s));
		}
		return *p;
	}

	/**
	 * Setter for DomType.OBJECT.
	 */
	void setObjectKey(string s, Value v)
	{
		_type = DomType.OBJECT;
		object[s] = v;
	}

	/**
	 * Set type as DomType.OBJECT.
	 */
	void setObject()
	{
		_type = DomType.OBJECT;
	}

	string[] keys()
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		return object.keys;
	}

	Value[] values()
	{
		enforceJEx(_type == DomType.OBJECT, "Value is not an object.");
		return object.values;
	}
}

private enum LONG_MAX = 9223372036854775807UL;

Value parse(string s)
{
	auto sax = new SAX(s);
	return parse(sax);
}

Value parse(InputStream input)
{
	auto sax = new SAX(input);
	return parse(sax);
}

Value parse(SAX sax)
{
	Value val;
	val.setObject();
	Value[] valueStack;
	string[] keyStack;

	void addKey(string key)
	{
		keyStack ~= key;
	}

	string getKey()
	{
		assert(valueStack.length >= 1);
		if (valueStack[$-1]._type == DomType.ARRAY) {
			return "";
		}
		assert(keyStack.length >= 1);
		auto key = keyStack[$-1];
		keyStack = keyStack[0 .. $-1];
		return key;
	}

	void pushValue(Value p)
	{
		valueStack ~= p;
	}

	Value popValue()
	{
		assert(valueStack.length > 1);
		auto val = valueStack[$-1];
		valueStack = valueStack[0 .. $-1];
		return val;
	}

	void addValue(Value val, string key="")
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

	auto current = &val;
	bool loop = true;
	void dg(Event event, const(ubyte)[] data)
	{
		if (event == Event.ERROR) {
			throw new DOMException(cast(string)data);
		}
		loop = event != Event.STOP;
		Value v;
		final switch (event) {
		case Event.ERROR:
			assert(false);
		case Event.STOP:
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
				ulong ul;
				parseUlong(cast(const(char)[])data, out ul);
				if (ul < LONG_MAX) {
					assert(canBeInteger(cast(const(char)[])data, true));
					long l;
					parseLong(cast(const(char)[])data, out l);
					v.integer(l);
					addValue(v, getKey());
					break;
				}
				v.unsigned(ul);
				addValue(v, getKey());
				break;
			} else if (canBeInteger(cast(const(char)[])data, true)) {
				long l;
				parseLong(cast(const(char[]))data, out l);
				v.integer(l);
				addValue(v, getKey());
				break;
			}
			double d;
			char[] buf;
			bool ret = parseDouble(cast(const(char)[])data, out d, ref buf);
			assert(ret);
			v.floating(d);
			addValue(v, getKey());
			break;
		case Event.STRING:
			v.str(unescapeString(cast(const(char)[])data));
			addValue(v, getKey());
			break;
		case Event.ARRAY_START:
			v.setArray();
			pushValue(v);
			break;
		case Event.ARRAY_END:
			if (valueStack.length > 1) {
				auto av = popValue();
				addValue(av, getKey());
			}
			break;
		case Event.OBJECT_START:
			v.setObject();
			pushValue(v);
			break;
		case Event.OBJECT_END:
			if (valueStack.length > 1) {
				auto ov = popValue();
				addValue(ov, getKey());
			}
			break;
		case Event.OBJECT_KEY:
			addKey(unescapeString(cast(const(char)[])data));
			break;
		}
	}
	while (loop) {
		sax.get(dg);
	}
	assert(valueStack.length == 1);
	return valueStack[$-1];
}

void dump(Value root, OutputStream output, bool prettyPrint = false, const(char)[] indent = "    ")
{
	auto builder = new Builder(output, prettyPrint, indent);

	void doDump(Value value)
	{
		final switch (value.type()) {
			case DomType.NULL:
				builder.buildNull();
				break;
			case DomType.BOOLEAN:
				builder.buildBoolean(value.boolean());
				break;
			case DomType.DOUBLE:
				builder.buildNumber(value.floating());
				break;
			case DomType.LONG:
				builder.buildNumber(value.integer());
				break;
			case DomType.ULONG:
				builder.buildNumber(value.unsigned());
				break;
			case DomType.STRING:
				builder.buildString(value.str());
				break;
			case DomType.OBJECT:
				builder.buildObjectStart();
				foreach (key; value.keys()) {
					builder.buildString(key);
					doDump(value.lookupObjectKey(key));
				}
				builder.buildObjectEnd();
				break;
			case DomType.ARRAY:
				builder.buildArrayStart();
				foreach (element; value.array()) {
					doDump(element);
				}
				builder.buildArrayEnd();
				break;
		}
	}

	doDump(root);
	builder.finalize();
}

string dump(Value value, bool prettyPrint = false, const(char)[] indent = "    ")
{
	auto output = new OutputStringBufferStream();
	dump(value, output, prettyPrint, indent);
	return output.get();
}
