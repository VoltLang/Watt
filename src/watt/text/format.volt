module watt.text.format;

import core.object;
import core.typeinfo;
import core.exception;
import core.stdc.stdio;
import watt.varargs;
import watt.conv;
import watt.text.sink;


fn format(formatString: const(char)[], ...) string
{
	vl: va_list;
	sink: StringSink;

	va_start(vl);
	formatImpl(sink.sink, formatString, ref _typeids, ref vl);
	va_end(vl);
	return sink.toString();
}

fn formatImpl(sink: Sink, formatString: const(char)[], ref _typeids: TypeInfo[], ref vl: va_list)
{
	formatting: bool;
	index: i32;

	for (i: u32 = 0; i < formatString.length; i++) {
		c: char = formatString[i];
		if (formatting) {
			switch (c) {
			case '%':
				sink("%");
				formatting = false;
				continue;
			case 'c':
				formatChar(sink, ref vl);
				break;
			case 'd':
				formatInt(sink, ref vl);
				break;
			case 'f':
				if (_typeids[index].type == Type.F32) {
					formatFloat(sink, ref vl);
				} else if (_typeids[index].type == Type.F64) {
					formatDouble(sink, ref vl);
				} else {
					throw new Exception("type to %f format mismatch");
				}
				break;
			case 'X':
				formatHex(sink, ref vl, _typeids[index]);
				break;
			case 'x':
				StringSink tmp;
				formatHex(tmp.sink, ref vl, _typeids[index]);
				sink(toLower(tmp.toString()));
				break;
			case 'p':
				formatPointer(sink, ref vl);
				break;
			case 's':
				formatType(sink, ref vl, _typeids[index]);
				break;
			default:
				throw new Exception(format("unknown format specifier '%c'", c));
			}
			formatting = false;
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

private fn formatByte(sink: Sink, ref vl: va_list)
{
	b := va_arg!i8(vl);
	sink(toString(b));
}

private fn formatUbyte(sink: Sink, ref vl: va_list)
{
	b := va_arg!u8(vl);
	sink(toString(b));
}

private fn formatShort(sink: Sink, ref vl: va_list)
{
	s := va_arg!i16(vl);
	sink(toString(s));
}

private fn formatUshort(sink: Sink, ref vl: va_list)
{
	s := va_arg!u16(vl);
	sink(toString(s));
}

private fn formatInt(sink: Sink, ref vl: va_list)
{
	i := va_arg!i32(vl);
	sink(toString(i));
}

private fn formatUint(sink: Sink, ref vl: va_list)
{
	i := va_arg!u32(vl);
	sink(toString(i));
}

private fn formatLong(sink: Sink, ref vl: va_list)
{
	l := va_arg!i64(vl);
	sink(toString(l));
}

private fn formatUlong(sink: Sink, ref vl: va_list)
{
	l := va_arg!u64(vl);
	sink(toString(l));
}

private fn formatFloat(sink: Sink, ref vl: va_list)
{
	f := va_arg!f32(vl);
	sink(toString(f));
}

private fn formatDouble(sink: Sink, ref vl: va_list)
{
	d := va_arg!f64(vl);
	sink(toString(d));
}

private fn formatChar(sink: Sink, ref vl: va_list)
{
	tmp: char[1];
	tmp[0] = va_arg!char(vl);
	sink(tmp);
}

private fn formatHex(sink: Sink, ref vl: va_list, id: TypeInfo)
{
	ul: u64;
	switch (id.type) {
	case Type.I8:
		ul = cast(u64)va_arg!i8(vl);
		break;
	case Type.U8:
		ul = cast(u64)va_arg!u8(vl);
		break;
	case Type.I16:
		ul = cast(u64)va_arg!i16(vl);
		break;
	case Type.U16:
		ul = cast(u64)va_arg!u16(vl);
		break;
	case Type.I32:
		ul = cast(u64)va_arg!i32(vl);
		break;
	case Type.U32:
		ul = cast(u64)va_arg!u32(vl);
		break;
	case Type.I64:
		ul = cast(u64)va_arg!i64(vl);
		break;
	case Type.U64:
		ul = va_arg!u64(vl);
		break;
	default:
		throw new Exception(format("Can't know how to hex-print type id %s.", id.type));
	}
	sink(toStringHex(ul));
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
		formatByte(sink, ref vl);
		break;
	case Type.U8:
		formatUbyte(sink, ref vl);
		break;
	case Type.I16:
		formatShort(sink, ref vl);
		break;
	case Type.U16:
		formatUshort(sink, ref vl);
		break;
	case Type.I32:
		formatInt(sink, ref vl);
		break;
	case Type.U32:
		formatUint(sink, ref vl);
		break;
	case Type.I64:
		formatLong(sink, ref vl);
		break;
	case Type.U64:
		formatUlong(sink, ref vl);
		break;
	case Type.F32:
		formatFloat(sink, ref vl);
		break;
	case Type.F64:
		formatDouble(sink, ref vl);
		break;
	case Type.Char:
		formatChar(sink, ref vl);
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
