// Copyright © 2015, David Herberth.  All rights reserved.
// Copyright © 2015, Bernard Helyer.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Parse [JSON](http://www.json.org) as a stream.
module watt.json.sax;

import core.c.stdio: snprintf;
import watt.io.std;
import watt.io.streams: InputStream, OutputStream;
import watt.text.ascii: isWhite, isDigit;
import watt.text.string: indexOf;
import watt.text.format: format;
import watt.math: isinf, isnan;
import util = watt.json.util;

private extern(C) {
	fn strcat(dest: char*, src: const(char)*) char*;
	fn strspn(str1: const(char)*, str2: const(char)*) size_t;
}

/*!
 * Exception thrown when an error occurs during building.
 */
class BuilderException : util.JSONException
{
	this(msg: string, location: string = __LOCATION__)
	{
		super(msg, location);
	}
}

//! Type of a JSON value.
enum Type
{
	//! A JSON `null` value.
	NULL,
	//! A JSON `true` or `false` value.
	BOOLEAN,
	//! A JSON number.
	NUMBER,
	//! A JSON string.
	STRING,
	//! A JSON object, everything between {}.
	OBJECT,
	//! A JSON array, everything between \[\].
	ARRAY
}

/*!
 * Events which will be produced by *JSON.get*.
 */
enum Event
{
	START, //!< The first event, marks the start of the JSON data.
	END, //!< The last event, marks the end of the JSON data.
	ERROR, //!< Event which will occour if invalid JSON is encountered.

	NULL, //!< A null was encountered.
	BOOLEAN, //!< A boolean was encountered.
	NUMBER, //!< A number was encountered.
	STRING, //!< A string was encountered.
	OBJECT_START, //!< The start of a JSON object was encountered.
	OBJECT_KEY, //!< A JSON object key was encountered (this is a string and still needs to be unescaped).
	OBJECT_END, //!< The end of a JSON object was encountered.
	ARRAY_START, //!< The start of a JSON array was encountered.
	ARRAY_END //!< The end of a JSON array was encountered.
}

/*!
 * Turn an `Event` into a human readable string.
 */
fn eventToString(event: Event) string
{
	switch (event) with (Event) {
		case START: return "start";
		case END: return "end";
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

/*!
 * Parses JSON.
 */
class SAX
{
public:
	ignoreGarbage: bool; //!< Ignore garbage/left over data after the root element is parsed.

protected:
	source: InputStream; //< Input source.
	buffer: u8[]; //< the complete buffer.
	reallocSize: size_t; //< resize to buffer.length + reallocSize if buffer is not big enough.

	current: const(u8)[]; //< slice to buffer.
	index: size_t;
	savedMark: size_t;
	isMarked: bool;

	state: ParserStack; //< holds the current state.

	lastError: string; //< last error.

public:
	/*!
	 * Creates a JSON object from an `InputStream`.
	 */
	this(source: InputStream, bufferSize: size_t = 65536, reallocSize: size_t = 16384) {
		this.source = source;
		this.buffer = new u8[](bufferSize);
		this.reallocSize = reallocSize;

		this.state.push(State.START);
	}

	/*!
	 * Creates a JSON object from an array.
	 */
	this(data: const(u8)[])
	{
		this.source = null;
		this.buffer = null;

		this.current = data;
		this.index = 0;

		this.state.push(State.START);
	}

	/*!
	 * Creates a JSON object from a string.
	 */
	this(data: const(char)[])
	{
		this(cast(const(u8)[])data);
	}

	/*!
	 * Continues parsing the input data and calsl the callback with
	 * the appropriate data.
	 *
	 * `data` is a slice to an internal buffer and will only be valid
	 * until the next `get` call. Strings and numbers still need to be
	 * further processed. e.g. through `parseNumber` and `unescapeString`.
	 */
	fn get(callback: scope dg (event: Event, data: const(u8)[]))
	{
		if (state.head == State.ERROR) {
			callback(Event.ERROR, cast(const(ubyte)[])lastError);
			return;
		}

		s: State;
		data: const(u8)[];
		next: char;
		getSuccess: bool = getImpl(out next);

		while (true) {
			switch (state.head) with (State) {
				case START:
					unget();
					state.pop();
					state.push(END);
					// CONTINUE is used to start with the root element
					// and not instantly stop because of the END state.
					state.push(CONTINUE);
					callback(Event.START, null);
					return;
				case END:
					callback(Event.END, null);
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
						if (state.head == END) {
							goto case END;
						}
						state.push(ERROR);
					}

					callback(Event.ERROR, cast(const(u8)[])lastError);
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
						if (!getImpl(out next)) break;
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
						if (!getImpl(out next)) break;
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
					if (!getImpl(out next)) break;
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
	fn error(message: string, file: string = __FILE__, line: const i32 = __LINE__)
	{
		lastError = message;
		state.push(State.ERROR);
	}

	fn eof() bool
	{
		skipWhite();
		if (source is null) {
			return index == current.length;
		}

		return source.eof();
	}

	fn mark()
	{
		savedMark = index;
		isMarked = true;
	}

	fn retrieve() const(u8)[]
	{
		assert(isMarked);
		isMarked = false;
		return current[savedMark..index];
	}

	fn getImpl(out c: char, skip: bool = true, advance: bool = true) bool
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
					buffer[0] = current.length > 0 ? current[$-1]: cast(ubyte)0;
					slice := source.read(buffer[1..$]);
					current = buffer[0..1+slice.length];
					index = 1;
				} else {
					if (savedMark == 0) {
						// the whole buffer is the marked range, we need a bigger buffer!
						buffer = new ubyte[](buffer.length + reallocSize);
					}
					len := current.length - savedMark;
					buffer[0..len] = current[savedMark..$];
					slice := source.read(buffer[len..$]);
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

	fn unget()
	{
		assert(index >= 1);
		index = index - 1;
	}

	fn skipWhite()
	{
		while (index < current.length && isWhite(current[index])) index++;
	}

	fn skipDigits() bool
	{
		c: char;

		while (true) {
			if (!getImpl(out c, false, false)) return false;
			if (isDigit(c)) {
				// advance by one
				++index;
			} else {
				break;
			}
		}

		return true;
	}

	fn expect(c: char, skip: bool = false) bool
	{
		g: char;
		if (!getImpl(out g, skip)) return false;
		if (g != c) {
			error(format("Expected '%c' got '%c'.", c, g));
			return false;
		}
		return true;
	}

	fn getString(out array: const(u8)[]) bool
	{
		if (!expect('"')) return false;

		mark();
		c: char;

		while (true) {
			if (!getImpl(out c, false)) return false;
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

	fn getNumber(out array: const(u8)[]) bool
	{
		c: char;
		mark();

		if (!getImpl(out c, false)) return false;
		if (c == '-') {
			if (!getImpl(out c, false)) return false;
		}

		if (c != '0') {
			if (!isDigit(c)) {
				error("Expected digit.");
				return false;
			}

			skipDigits();
		}

		if (!getImpl(out c, false, false)) return false;
		if (c == '.') {
			++index;
			skipDigits();
		}

		if (!getImpl(out c, false, false)) return false;
		if (c == 'e' || c == 'E') {
			++index;
			if (!getImpl(out c, false)) return false;
			if (c != '+' || c != '-') {
				error("Expected '+' or '-'.");
				return false;
			}

			if (!getImpl(out c, false)) return false;
			if (!isDigit(c)) {
				error("Expected digit.");
				return false;
			}

			skipDigits();
		}

		array = retrieve();
		return true;
	}

	fn getBoolean(out array: const(u8)[]) bool
	{
		mark();

		c: char;
		if (!getImpl(out c)) return false;
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

	fn getNull(out array: const(u8)[]) bool
	{
		mark();

		c: char;
		if (!getImpl(out c)) return false;
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

/*!
 * The main class to build/write JSON.
 */
class Builder
{
protected:
	output: OutputStream;

	prettyPrint: bool;
	indent: const(char)[];

	indentLevel: size_t;

	buffer: char[];
	state: ParserStack;

public:
	/*!
	 * Creates a new `JSONBuilder` object.
	 *
	 * @Param output The `OutputStream` to emit to.
	 * @Param prettyPrint If true emit formatted JSON
	 * @Param indent: Only relevant if `prettyPrint` is enabled,
	 * sets the indentation per level.
	 */
	this(output: OutputStream, prettyPrint: bool = false, indent: const(char)[] = "    ")
	{
		this.output = output;

		this.prettyPrint = prettyPrint;
		this.indent = indent;

		this.indentLevel = 0;

		this.state.push(State.START);
	}

	/*!
	 * Writes a null value.
	 */
	fn buildNull()
	{
		prepareAndCheck();
		output.write("null");
	}

	/*!
	 * Writes a number.
	 */
	fn buildNumber(number: f64)
	{
		if (isnan(number) || isinf(number)) {
			throw new BuilderException("Invalid number.");
		}
		prepareAndCheck();

		// TODO use vrt_format_* functions.
		buf: char[32];
		len := cast(size_t)snprintf(buf.ptr, buf.length, "%.20g", number);
		if (len + 2 <= buf.length && strspn(buf.ptr, "0123456789-") == len) {
			strcat(buf.ptr, ".0");
			len += 2;
		}
		output.write(buf[0 .. len]);
	}

	/*!
	 * Writes a number.
	 */
	fn buildNumber(number: i32)
	{
		buildNumber(cast(i64)number);
	}

	/*!
	 * Writes a number.
	 */
	fn buildNumber(number: i64)
	{
		prepareAndCheck();

		// TODO use vrt_format_* functions.
		buf: char[20];
		len := cast(size_t)snprintf(buf.ptr, buf.length, "%d", number);
		output.write(buf[0 .. len]);
	}

	/*!
	 * Writes a string.  
	 * If `escape` is `true` (default) the string will
	 * be escaped, set this to `false` if you want to write an
	 * already escaped strings.
	 */
	fn buildString(str: const(char)[], escape: bool = true)
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

	/*!
	 * Writes a boolean.
	 */
	fn buildBoolean(b: bool)
	{
		prepareAndCheck();
		if (b) {
			output.write("true");
		} else {
			output.write("false");
		}
	}

	/*!
	 * Writes the start of a JSON object.  
	 * JSON keys are expected to be built with `buildString`.
	 */
	fn buildObjectStart()
	{
		prepareAndCheck();
		state.push(State.OBJECT_START);
		output.write("{");
		++indentLevel;
	}

	/*!
	 * Writes the end of a JSON object.
	 */
	fn buildObjectEnd()
	{
		s := state.pop();
		if (s != State.OBJECT && s != State.OBJECT_START) {
			throw new BuilderException("Wrong state to end object.");
		}

		--indentLevel;
		if (prettyPrint) {
			output.write("\n");
			foreach (i; 0 .. indentLevel) {
				output.write(indent);
			}
		}

		output.write("}");
	}

	/*!
	 * Writes the start of a JSON array.
	 */
	fn buildArrayStart()
	{
		state.push(State.ARRAY_START);
		output.write("[");
		++indentLevel;
	}

	/*!
	 * Writes the end of a JSON array.
	 */
	fn buildArrayEnd()
	{
		s := state.pop();
		if (s != State.ARRAY && s != State.ARRAY_START) {
			throw new BuilderException("Wrong state to end array.");
		}

		--indentLevel;
		if (prettyPrint) {
			output.write("\n");
			for (i: size_t = 0; i < indentLevel; ++i) {
				output.write(indent);
			}
		}

		output.write("]");
	}

	/*!
	 * Finalizes the JSON.  
	 * This is optional but recommended,
	 * it checks for malformed JSON and writes an additional newline
	 * if `prettyPrint` is enabled.
	 */
	fn finalize()
	{
		if (state.head != State.START && state.head != State.END) {
			throw new BuilderException("Invalid state.");
		}

		if (prettyPrint) {
			output.write("\n");
		}
	}

protected:
	fn prepareAndCheck(isString: bool = false)
	{
		doPretty: bool = prettyPrint;

		if (state.used == 0) {
			throw new BuilderException("Invalid state.");
		}

		switch (state.head) with (State) {
			case START:
				state.pop();
				state.push(END);
				break;
			case END:
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

			for (i: size_t = 0; i < indentLevel; ++i) {
				output.write(indent);
			}
		}
	}
}


private enum State
{
	START,
	END,
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
	data: State[];
	used: size_t;

	fn push(status: State)
	{
		if (data.length <= used) {
			newData := new State[](data.length + 128);
			newData[0..data.length] = data[];
			data = newData;
		}

		data[used++] = status;
	}

	fn pop() State
	{
		assert(used >= 1);
		return data[--used];
	}

	@property fn head() State
	{
		assert(data.length > used);
		return data[used-1];
	}
}
