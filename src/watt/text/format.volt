/*!
 * Structured string formatting.
 *
 * This module contains the `format` function, a versatile string formatter.
 * The `format` function is also used by @ref watt.io.std.writef functions and similar
 * to handle their formatting.
 *
 * The format string syntax is similar to C's `printf`, but requires less explicit
 * typing. In most cases, `%s` will suffice to do the 'right thing'.
 *
 * ### Examples
 * ```volt
 * format("Hello %s", "your name");  // "Hello your name"
 * format("%03s", 32);  // "032"
 * ```
 */
module watt.text.format;

import core.object;
import core.typeinfo;
import core.exception;
import core.varargs;
import core.rt.format;
import watt.conv;
import watt.text.sink;
import watt.text.ascii;
import watt.text.utf;


/*!
 * Formats various arguments into a string by interpreting formatString.
 *
 * Format specifiers are specified with the character `%`.  
 * %(flag)(width)(type)  
 * The flag and width fields are optional.
 *
 * The flags modify how the printing is formatted.
 *   - ` `: prefix positive integers with a space.
 *   - `0`: pad the string with zeros, rather than spaces.
 * The width flag pads the output if it is less than the number given.
 * For example,  
 *   "%3s", "ab" = " ab"  
 *   "%03s", "ab" = "0ab"
 *
 * And the type denotes what type should be printed. They are as follows:
 *    - `%`: print a `%` character.
 *    - `s`: perform the default action for the corresponding type.
 *    - `d`: print an integer.
 *    - `x`: print a lower case hex string.
 *    - `X`: print an upper case hex string.
 *    - `b`: print a binary string.
 *    - `p`: print the value appropriately as a pointer.
 *    - `f`: print a floating point value.
 *    - `c`: print a single character.
 */
fn format(formatString: const(char)[], ...) string
{
	vl: va_list;
	sink: StringSink;

	va_start(vl);
	formatImpl(sink.sink, formatString, ref _typeids, ref vl);
	va_end(vl);
	return sink.toString();
}

//! Format using the above rules, but into a `Sink`.
fn format(sink: Sink, formatString: const(char)[], ...)
{
	vl: va_list;

	va_start(vl);
	formatImpl(sink, formatString, ref _typeids, ref vl);
	va_end(vl);
}

/*!
 * Format using the above rules, but into a `Sink`, with
 * an explicit list of `TypeInfo`s, and an explicit `va_list`.
 *
 * This allows variadic functions to use `format` to process their input.
 */
fn formatImpl(sink: Sink, formatString: const(char)[], ref _typeids: TypeInfo[], ref vl: va_list)
{
	formatting: bool;
	index: i32;

	zero: bool;
	space: bool;
	dot: bool;
	padding: i32 = - 1;

	fn output(str: SinkArg)
	{
		padding -= cast(i32)str.length;
		if (padding < 0) {
			padding = 0;
		}
		padc := zero ? "0" : " ";
		outputSpacePadding := false;
		foreach (0 .. padding) {
			sink(padc);
			outputSpacePadding = !zero;
		}
		if (space && !outputSpacePadding) {
			i := toInt(str);
			if (i >= 0) {
				sink(" ");
			}
		}
		padding = 0;
		zero = false;
		space = false;
		formatting = false;
		sink(str);
	}

	for (i: u32 = 0; i < formatString.length; i++) {
		c: char = formatString[i];
		if (formatting) {
			switch (c) {
			case '%':
				output("%");
				continue;
			case 'c':
				tmp: StringSink;
				formatChar(tmp.sink, ref vl);
				tmp.toSink(output);
				break;
			case 'd':
				tmp: StringSink;
				vrt_format_i64(tmp.sink, va_arg!i32(vl));
				tmp.toSink(output);
				break;
			case 'f':
				tmp: StringSink;
				if (_typeids[index].type == Type.F32) {
					vrt_format_f32(tmp.sink, va_arg!f32(vl), dot ? padding : -1);
				} else if (_typeids[index].type == Type.F64) {
					vrt_format_f64(tmp.sink, va_arg!f64(vl), dot ? padding : -1);
				} else {
					asInt: i64;
					switch (_typeids[index].type) {
					case Type.I8:
						asInt = cast(i64)va_arg!i8(vl);
						break;
					case Type.I16:
						asInt = cast(i64)va_arg!i16(vl);
						break;
					case Type.I32:
						asInt = cast(i64)va_arg!i32(vl);
						break;
					case Type.I64:
						asInt = cast(i64)va_arg!i64(vl);
						break;
					default:
						throw new Exception("type to %f format mismatch");
					}
					vrt_format_f64(tmp.sink, cast(f64)asInt);
				}
				tmp.toSink(output);
				break;
			case 'X':
				tmp: StringSink;
				formatHex(tmp.sink, ref vl, _typeids[index]);
				tmp.toSink(output);
				break;
			case 'x':
				tmp: StringSink;
				formatHex(tmp.sink, ref vl, _typeids[index]);
				output(toLower(tmp.toString()));
				break;
			case 'b':
				tmp: StringSink;
				formatBinary(tmp.sink, ref vl, _typeids[index]);
				tmp.toSink(output);
				break;
			case 'p':
				tmp: StringSink;
				formatPointer(tmp.sink, ref vl);
				tmp.toSink(output);
				break;
			case 's':
				tmp: StringSink;
				formatType(tmp.sink, ref vl, _typeids[index]);
				tmp.toSink(output);
				break;
			case '0':
				zero = true;
				continue;
			case ' ':
				space = true;
				continue;
			case '.':
				dot = true;
				padding = 0;
				continue;
			default:
				if (isDigit(c)) {
					paddingSink: StringSink;
					do {
						paddingSink.sink([c]);
						i++;
						c = formatString[i];
					} while (isDigit(c) && i < formatString.length);
					padding = toInt(paddingSink.toString());
					i--;
					continue;
				}
				throw new Exception(format("unknown format specifier '%c'", c));
			}
			index++;
			continue;
		}
		if (c == '%') {
			formatting = true;
		} else {
			sink(formatString[i .. i+1]);
		}
	}
	//sink("\0");
}

private fn formatNull(sink: Sink, ref vl: va_list)
{
	sink("null");
}

private fn formatObject(sink: Sink, ref vl: va_list)
{
	obj := va_arg!Object(vl);
	if (obj is null) {
		formatNull(sink, ref vl);
		return;
	}
	sink(obj.toString());
}

private fn formatString(sink: Sink, ref vl: va_list)
{
	s := va_arg!char[](vl);
	if (s.length > 1 && s[s.length - 1] == '\0') {
		s = s[0 .. s.length - 1];
	}
	sink(s);
}

private fn formatChar(sink: Sink, ref vl: va_list)
{
	tmp: char[1];
	tmp[0] = va_arg!char(vl);
	sink(tmp);
}

private fn formatDchar(sink: Sink, ref vl: va_list)
{
//	tmp: dchar[1];
//	tmp[0] = va_arg!dchar(vl);
	sink(encode(va_arg!dchar(vl)));
}

private fn formatHex(sink: Sink, ref vl: va_list, id: TypeInfo)
{
	ul: u64;
	switch (id.type) {
	case Type.I8:
		// Unsigned to not sign extend.
		ul = va_arg!u8(vl);
		break;
	case Type.U8:
		ul = va_arg!u8(vl);
		break;
	case Type.I16:
		// Unsigned to not sign extend.
		ul = va_arg!u16(vl);
		break;
	case Type.U16:
		ul = va_arg!u16(vl);
		break;
	case Type.I32:
		// Unsigned to not sign extend.
		ul = va_arg!u32(vl);
		break;
	case Type.U32:
		ul = va_arg!u32(vl);
		break;
	case Type.I64:
		// No risk for sign extend but just to skip the cast.
		ul = va_arg!u64(vl);
		break;
	case Type.U64:
		ul = va_arg!u64(vl);
		break;
	default:
		throw new Exception(format("Don't know how to hex-print type id %s.", id.type));
	}
	vrt_format_hex(sink, ul, 0);
}

private fn formatBinary(sink: Sink, ref vl: va_list, id: TypeInfo)
{
	ul: u64;
	switch (id.type) {
	case Type.I8:
		sink(toStringBinary(va_arg!i8(vl)));
		break;
	case Type.U8:
		sink(toStringBinary(va_arg!u8(vl)));
		break;
	case Type.I16:
		sink(toStringBinary(va_arg!i16(vl)));
		break;
	case Type.U16:
		sink(toStringBinary(va_arg!u16(vl)));
		break;
	case Type.I32:
		sink(toStringBinary(va_arg!i32(vl)));
		break;
	case Type.U32:
		sink(toStringBinary(va_arg!u32(vl)));
		break;
	case Type.I64:
		sink(toStringBinary(va_arg!i64(vl)));
		break;
	case Type.U64:
		sink(toStringBinary(va_arg!u64(vl)));
		break;
	default:
		throw new Exception(format("Don't know how to binary-print type id %s.", id.type));
	}
}

private fn formatPointer(sink: Sink, ref vl: va_list)
{
	p := va_arg!void*(vl);
	sink(toString(p));
}

private fn formatArray(sink: Sink, ref vl: va_list, id: TypeInfo)
{
	if (id.base.type == Type.Char) {
		formatString(sink, ref vl);
	} else {
		v := va_arg!void[](vl);
		old := vl;
		vl = v.ptr;
		sink("[");
		foreach (i; 0 .. v.length) {
			if (id.base.type == Type.Char) {
				sink("\"");
				formatString(sink, ref vl);
				sink("\"");
			} else {
				formatType(sink, ref vl, id.base);
			}
			if (i < v.length - 1) {
				sink(", ");
			}
		}
		vl = old;
		sink("]");
	}
}

private fn formatType(sink: Sink, ref vl: va_list, id: TypeInfo)
{
	switch (id.type) {
	case Type.Class:
		formatObject(sink, ref vl);
		break;
	case Type.Array:
		formatArray(sink, ref vl, id);
		break;
	case Type.Bool:
		formatBool(sink, ref vl);
		break;
	case Type.I8:
		vrt_format_i64(sink, va_arg!i8(vl));
		break;
	case Type.U8:
		vrt_format_u64(sink, va_arg!u8(vl));
		break;
	case Type.I16:
		vrt_format_i64(sink, va_arg!i16(vl));
		break;
	case Type.U16:
		vrt_format_u64(sink, va_arg!u16(vl));
		break;
	case Type.I32:
		vrt_format_i64(sink, va_arg!i32(vl));
		break;
	case Type.U32:
		vrt_format_u64(sink, va_arg!u32(vl));
		break;
	case Type.I64:
		vrt_format_i64(sink, va_arg!i64(vl));
		break;
	case Type.U64:
		vrt_format_u64(sink, va_arg!u64(vl));
		break;
	case Type.F32:
		vrt_format_f32(sink, va_arg!f32(vl));
		break;
	case Type.F64:
		vrt_format_f64(sink, va_arg!f64(vl));
		break;
	case Type.Char:
		formatChar(sink, ref vl);
		break;
	case Type.Dchar:
		formatDchar(sink, ref vl);
		break;
	case Type.Function, Type.Delegate, Type.Pointer:
		formatPointer(sink, ref vl);
		break;
	default:
		throw new Exception(format("Don't know how to print type id %s.", id.type));
	}
}

private fn formatBool(sink: Sink, ref vl: va_list)
{
	b := va_arg!bool(vl);
	sink(b ? "true": "false");
}
