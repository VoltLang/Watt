// Copyright © 2015, David Herberth.  All rights reserved.
// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.text.json.sax;

import core.stdc.stdio : snprintf;
import watt.io.std;
import watt.io.streams : InputStream, OutputStream;
import watt.text.ascii : isWhite, isDigit;
import watt.text.string : indexOf;
import watt.text.format : format;
import watt.math : isinf, isnan;
import util = watt.text.json.util;

private extern(C) {
	char* strcat(char* dest, const(char)* src);
	size_t strspn(const(char)* str1, const(char)* str2 );
}

/**
 * Exception thrown when an error occurs during building.
 */
class BuilderException : util.JSONException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

enum Type
{
	NULL,
	BOOLEAN,
	NUMBER,
	STRING,
	OBJECT,
	ARRAY
}

/**
 * Events which will be produced by *JSON.get*.
 */
enum Event
{
	START, ///< The first event, marks the start of the JSON data.
	STOP, ///< The last event, marks the end of the JSON data.
	ERROR, ///< Event which will occour if invalid JSON is encountered.

	NULL, ///< A null was encountered.
	BOOLEAN, ///< A boolean was encountered.
	NUMBER, ///< A number was encountered.
	STRING, ///< A string was encountered.
	OBJECT_START, ///< The start of a JSON object was encountered.
	OBJECT_KEY, ///< A JSON object key was encountered (this is a string and still needs to be unescaped).
	OBJECT_END, ///< The end of a JSON object was encountered.
	ARRAY_START, ///< The start of a JSON array was encountered.
	ARRAY_END ///< The end of a JSON array was encountered.
}

/**
 * Turn a *Event* into a human readable string.
 */
string eventToString(Event event)
{
	switch (event) with (Event) {
		case START: return "start";
		case STOP: return "stop";
		case ERROR: return "error";
		case NULL: return "null";
		case BOOLEAN: return "boolean";
		case NUMBER: return "number";
		case STRING: return "string";
		case OBJECT_START: return "object_start";
		case OBJECT_KEY: return "object_key";
		case OBJECT_END: return "object_end";
		case ARRAY_START: return "array_start";
		case ARRAY_END: return "array_end";
		default: assert(false);
	}

	assert(false);
}

/**
 * Main class for parsing JSON.
 */
class SAX
{
public:
	bool ignoreGarbage; ///< Ignore garbage/left over data after the root element is parsed.

protected:
	InputStream source; //< Input source.
	ubyte[] buffer; //< the complete buffer.
	size_t reallocSize; //< resize to buffer.length + reallocSize if buffer is not big enough.

	const(ubyte)[] current; //< slice to buffer.
	size_t index;
	size_t savedMark;
	bool isMarked;

	ParserStack state; //< holds the current state.

	string lastError; //< last error.

public:
	/**
	 * Creates a JSON object from an InputStream.
	 */
	this(InputStream source, size_t bufferSize = 65536, size_t reallocSize = 16384) {
		this.source = source;
		this.buffer = new ubyte[](bufferSize);
		this.reallocSize = reallocSize;

		this.state.push(State.START);
	}

	/**
	 * Creates a JSON object from an array.
	 */
	this(const(ubyte)[] data)
	{
		this.source = null;
		this.buffer = null;

		this.current = data;
		this.index = 0;

		this.state.push(State.START);
	}

	/**
	 * Creates a JSON object from a string.
	 */
	this(const(char)[] data)
	{
		this(cast(const(ubyte)[])data);
	}

	/**
	 * Continues parsing the input data and call the callback with the appropriate data.
	 *
	 * *data* is a slice to an internal buffer and will only be valid until the next
	 * *get* call. strings and numbers still need to be further processed e.g. throught
	 * *parseNumber* and *unescapeString*.
	 */
	void get(scope void delegate(Event event, const(ubyte)[] data) callback)
	{
		if (state.head == State.ERROR) {
			callback(Event.ERROR, cast(const(ubyte)[])lastError);
			return;
		}

		State s;
		const(ubyte)[] data;
		char next;
		bool getSuccess = get(out next);

		while (true) {
			switch (state.head) with (State) {
				case START:
					unget();
					state.pop();
					state.push(STOP);
					// CONTINUE is used to start with the root element
					// and not instantly stop because of the STOP state.
					state.push(CONTINUE);
					callback(Event.START, null);
					return;
				case STOP:
					callback(Event.STOP, null);
					if (!ignoreGarbage && getSuccess) {
						error("Too much data.");
						break;
					}
					return;
				case CONTINUE:
					state.pop();
					goto default;
				case ERROR:
					if (!getSuccess && eof()) {
						// could be real EOF or just the end.
						state.pop();
						if (state.head == STOP) {
							goto case STOP;
						}
						state.push(ERROR);
					}

					callback(Event.ERROR, cast(const(ubyte)[])lastError);
					return;
				case ARRAY_START:
					// The point of this section is to make sure
					// either the array is empty or starts with an item
					// and not ',' which ARRAY does ignore.
					state.pop();
					state.push(ARRAY);
					if (next == ']') {
						goto default;
					}
					state.push(ARRAY_ITEM);
					break;
				case ARRAY:
					if (next == ']') {
						goto default;
					}
					state.push(ARRAY_ITEM);
					if (next == ',') {
						if (!get(out next)) break;
					}
					break;
				case ARRAY_ITEM:
					state.pop();
					goto default;
				case OBJECT_START:
					// The point of this section is to make sure
					// either the object is empty or starts with a key
					// and not ',' which OBJECT does ignore.
					state.pop();
					state.push(OBJECT);
					if (next == '}') {
						goto default;
					}
					state.push(OBJECT_KEY);
					break;
				case OBJECT:
					if (next == '}') {
						goto default;
					}
					state.push(OBJECT_KEY);
					if (next == ',') {
						if (!get(out next)) break;
					}
					break;
				case OBJECT_KEY:
					if (next == '}') {
						error("Trailing comma at end of object members list.");
						break;
					}
					if (next != '"') {
						error("Object keys must be strings.");
						break;
					}
					state.pop();
					state.push(OBJECT_VALUE);
					unget();
					if (!getString(out data)) break;
					callback(Event.OBJECT_KEY, data);
					return;
				case OBJECT_VALUE:
					if (next != ':') {
						error("Expected colon.");
						break;
					}
					if (!get(out next)) break;
					state.pop();
					goto default;
				default:
					// parse any value
					switch (next) {
						case '[':
							state.push(State.ARRAY_START);
							callback(Event.ARRAY_START, null);
							return;
						case ']':
							s = state.pop();
							if (s != State.ARRAY) {
								error("Unexpected array end.");
								break;
							}
							callback(Event.ARRAY_END, null);
							return;
						case '{':
							state.push(State.OBJECT_START);
							callback(Event.OBJECT_START, null);
							return;
						case '}':
							s = state.pop();
							if (s != State.OBJECT) {
								error("Unexpected object end.");
								break;
							}
							callback(Event.OBJECT_END, null);
							return;
						case '"':
							unget();
							if (!getString(out data)) break;
							callback(Event.STRING, data);
							return;
						case '0': case '1': case '2': case '3': case '4':
						case '5': case '6': case '7': case '8': case '9':
						case '-':
							unget();
							if (!getNumber(out data)) break;
							callback(Event.NUMBER, data);
							return;
						case 't':
						case 'T':
						case 'f':
						case 'F':
							unget();
							if (!getBoolean(out data)) break;
							callback(Event.BOOLEAN, data);
							return;
						case 'n':
						case 'N':
							unget();
							if (!getNull(out data)) break;
							callback(Event.NULL, data);
							return;
						default:
							error(format("Unexpected character: '%c'.", next));
							break;
					}
					break;
			}
		}
	}

protected:
	void error(string message, string file = __FILE__, const int line = __LINE__)
	{
		lastError = message;
		state.push(State.ERROR);
	}

	bool eof()
	{
		skipWhite();
		if (source is null) {
			return index == current.length;
		}

		return source.eof();
	}

	void mark()
	{
		savedMark = index;
		isMarked = true;
	}

	const(ubyte)[] retrieve()
	{
		assert(isMarked);
		isMarked = false;
		return current[savedMark..index];
	}

	bool get(out char c, bool skip = true, bool advance = true)
	{
		if (skip) {
			skipWhite();
		}

		do {
			if (index >= current.length) {
				if (source is null || source.eof()) {
					error("Got EOF too early.");
					return false;
				}

				if (!isMarked) {
					// copy over the last byte of the current buffer to make unget work.
					buffer[0] = current.length > 0 ? current[$-1] : cast(ubyte)0;
					auto slice = source.read(buffer[1..$]);
					current = buffer[0..1+slice.length];
					index = 1;
				} else {
					if (savedMark == 0) {
						// the whole buffer is the marked range, we need a bigger buffer!
						buffer = new ubyte[](buffer.length + reallocSize);
					}
					auto len = current.length - savedMark;
					buffer[0..len] = current[savedMark..$];
					auto slice = source.read(buffer[len..$]);
					current = buffer[0..len+slice.length];
					index = len;
					savedMark = 0;
				}

				if (skip) {
					skipWhite();
				}
			}
		} while (current.length <= index);

		c = cast(char)current[index];
		if (advance) {
			++index;
		}
		return true;
	}

	void unget()
	{
		assert(index >= 1);
		index = index - 1;
	}

	void skipWhite()
	{
		while (index < current.length && isWhite(current[index])) index++;
	}

	bool skipDigits()
	{
		char c;

		while (true) {
			if (!get(out c, false, false)) return false;
			if (isDigit(c)) {
				// advance by one
				++index;
			} else {
				break;
			}
		}

		return true;
	}

	bool expect(char c, bool skip = false)
	{
		char g;
		if (!get(out g, skip)) return false;
		if (g != c) {
			error(format("Expected '%c' got '%c'.", c, g));
			return false;
		}
		return true;
	}

	bool getString(out const(ubyte)[] array)
	{
		if (!expect('"')) return false;

		mark();
		char c;

		while (true) {
			if (!get(out c, false)) return false;
			if (c == '\\') {
				++index;
			} else if(c == '"') {
				break;
			}
		}

		array = retrieve(); // remove last "
		array = array[0..$-1];
		return true;
	}

	bool getNumber(out const(ubyte)[] array)
	{
		char c;
		mark();

		if (!get(out c, false)) return false;
		if (c == '-') {
			if (!get(out c, false)) return false;
		}

		if (c != '0') {
			if (!isDigit(c)) {
				error("Expected digit.");
				return false;
			}

			skipDigits();
		}

		if (!get(out c, false, false)) return false;
		if (c == '.') {
			++index;
			skipDigits();
		}

		if (!get(out c, false, false)) return false;
		if (c == 'e' || c == 'E') {
			++index;
			if (!get(out c, false)) return false;
			if (c != '+' || c != '-') {
				error("Expected '+' or '-'.");
				return false;
			}

			if (!get(out c, false)) return false;
			if (!isDigit(c)) {
				error("Expected digit.");
				return false;
			}

			skipDigits();
		}

		array = retrieve();
		return true;
	}

	bool getBoolean(out const(ubyte)[] array)
	{
		mark();

		char c;
		if (!get(out c)) return false;
		if (c == 't' || c == 'T') {
			if (!expect('r')) return false;
			if (!expect('u')) return false;
			if (!expect('e')) return false;
		} else if(c == 'f' || c == 'F') {
			if (!expect('a')) return false;
			if (!expect('l')) return false;
			if (!expect('s')) return false;
			if (!expect('e')) return false;
		} else {
			error("Expected boolean.");
			return false;
		}

		array = retrieve();
		return true;
	}

	bool getNull(out const(ubyte)[] array)
	{
		mark();

		char c;
		if (!get(out c)) return false;
		if (c == 'n' || c == 'N') {
			if (!expect('u')) return false;
			if (!expect('l')) return false;
			if (!expect('l')) return false;
		} else {
			error("Expected null.");
			return false;
		}

		array = retrieve();
		return true;
	}
}

/**
 * The main class to build/write JSON.
 */
class Builder
{
protected:
	OutputStream output;

	bool prettyPrint;
	const(char)[] indent;

	size_t indentLevel;

	char[] buffer;
	ParserStack state;

public:
	/**
	 * Creates a new *JSONBuilder* object.
	 *
	 * *prettyPrint*: If true emit formatted JSON
	 * *indent*: Only relevant if *prettyPrint* is enabled, sets the indentation per level.
	 */
	this(OutputStream output, bool prettyPrint = false, const(char)[] indent = "    ")
	{
		this.output = output;

		this.prettyPrint = prettyPrint;
		this.indent = indent;

		this.indentLevel = 0;

		this.state.push(State.START);
	}

	/**
	 * Writes a null value.
	 */
	void buildNull()
	{
		prepareAndCheck();
		output.write("null");
	}

	/**
	 * Writes a number.
	 */
	void buildNumber(double number)
	{
		if (isnan(number) || isinf(number)) {
			throw new BuilderException("Invalid number.");
		}
		prepareAndCheck();

		char[32] buffer;
		auto len = cast(size_t)snprintf(buffer.ptr, buffer.length, "%.20g", number);
		if (len + 2 <= buffer.length && strspn(buffer.ptr, "0123456789-") == len) {
			strcat(buffer.ptr, ".0");
			len += 2;
		}
		output.write(buffer[0 .. len]);
	}

	/**
	 * Writes a number.
	 */
	void buildNumber(int number)
	{
		buildNumber(cast(long)number);
	}

	/**
	 * Writes a number.
	 */
	void buildNumber(long number)
	{
		prepareAndCheck();

		char[20] buffer;
		auto len = cast(size_t)snprintf(buffer.ptr, buffer.length, "%d", number);
		output.write(buffer[0 .. len]);
	}

	/**
	 * Writes a string, if *escape* is *true* (default) the string will
	 * be escaped, set this to false if you want to write an already escaped string.
	 */
	void buildString(const(char)[] str, bool escape = true)
	{
		prepareAndCheck(true);
		output.write("\"");
		if (escape) {
			output.write(util.escapeString(str, ref buffer));
		} else {
			output.write(str);
		}
		output.write("\"");
	}

	/**
	 * Writes a boolean.
	 */
	void buildBoolean(bool b)
	{
		prepareAndCheck();
		if (b) {
			output.write("true");
		} else {
			output.write("false");
		}
	}

	/**
	 * Writes the start of a JSON object.
	 * JSON keys are expected to be built with *buildString*.
	 */
	void buildObjectStart()
	{
		prepareAndCheck();
		state.push(State.OBJECT_START);
		output.write("{");
		++indentLevel;
	}

	/**
	 * Writes the end of a JSON object.
	 */
	void buildObjectEnd()
	{
		auto s = state.pop();
		if (s != State.OBJECT && s != State.OBJECT_START) {
			throw new BuilderException("Wrong state to end object.");
		}

		--indentLevel;
		if (prettyPrint) {
			output.write("\n");
			for (size_t i = 0; i < indentLevel; ++i) {
				output.write(indent);
			}
		}

		output.write("}");
	}

	/**
	 * Writes the start of a JSON array.
	 */
	void buildArrayStart()
	{
		state.push(State.ARRAY_START);
		output.write("[");
		++indentLevel;
	}

	/**
	 * Writes the end of a JSON array.
	 */
	void buildArrayEnd()
	{
		auto s = state.pop();
		if (s != State.ARRAY && s != State.ARRAY_START) {
			throw new BuilderException("Wrong state to end array.");
		}

		--indentLevel;
		if (prettyPrint) {
			output.write("\n");
			for (size_t i = 0; i < indentLevel; ++i) {
				output.write(indent);
			}
		}

		output.write("]");
	}

	/**
	 * Finalizes the JSON, this is optional but recommended to call,
	 * it checks for malformed JSON and writes an additional newline
	 * if *prettyPrint* is enabled.
	 */
	void finalize()
	{
		if (state.head != State.START && state.head != State.STOP) {
			throw new BuilderException("Invalid state.");
		}

		if (prettyPrint) {
			output.write("\n");
		}
	}

protected:
	void prepareAndCheck(bool isString = false)
	{
		bool doPretty = prettyPrint;

		if (state.used == 0) {
			throw new BuilderException("Invalid state.");
		}

		switch (state.head) with (State) {
			case START:
				state.pop();
				state.push(STOP);
				break;
			case STOP:
				throw new BuilderException("Only one root element allowed.");
			case OBJECT_START:
				state.pop();
				state.push(OBJECT_KEY);
				if (!isString) {
					throw new BuilderException("Keys must be strings.");
				}
				break;
			case OBJECT_KEY:
				state.pop();
				state.push(OBJECT);
				output.write(":");
				if (prettyPrint) {
					doPretty = false;
					output.write(" ");
				}
				break;
			case OBJECT:
				state.pop();
				state.push(OBJECT_KEY);
				output.write(",");
				if (!isString) {
					throw new BuilderException("Keys must be strings.");
				}
				break;
			case ARRAY_START:
				state.pop();
				state.push(ARRAY);
				break;
			case ARRAY:
				output.write(",");
				break;
			case ERROR:
				// Never supposed to happen.
				throw new BuilderException("Error.");
			default:
				throw new BuilderException("Unhandled state.");
		}

		if (doPretty) {
			output.write("\n");

			for (size_t i = 0; i < indentLevel; ++i) {
				output.write(indent);
			}
		}
	}
}


private enum State
{
	START,
	STOP,
	CONTINUE,
	ERROR,
	OBJECT, // currently parsing an object
	OBJECT_START, // currently at the very beginning of an object
	OBJECT_KEY, // currently parsing an object and expecting a key
	OBJECT_VALUE, // currently parsing an object and expecting a value
	ARRAY, // currently parsing an array
	ARRAY_START, // currently at the very beginning of an array
	ARRAY_ITEM, // currently parsing an array and expecting an item
}

struct ParserStack
{
	State[] data;
	size_t used;

	void push(State status)
	{
		if (data.length <= used) {
			auto newData = new State[](data.length + 128);
			newData[0..data.length] = data[];
			data = newData;
		}

		data[used++] = status;
	}

	State pop()
	{
		assert(used >= 1);
		return data[--used];
	}

	@property State head()
	{
		assert(data.length > used);
		return data[used-1];
	}
}
