module watt.text.format;

import core.object;
import core.typeinfo;
import core.exception;
import core.stdc.stdio;
import watt.varargs;
import watt.conv;


fn format(formatString : const(char)[], ...) string
{
	vl : va_list;
	buf : char[];

	va_start(vl);
	formatImpl(formatString, ref _typeids, ref buf, ref vl);
	va_end(vl);
	return cast(string) buf;
}

fn formatImpl(formatString : const(char)[], ref _typeids : TypeInfo[], ref buf : char[], ref vl : va_list)
{
	formatting : bool;
	index : i32;

	for (i : u32 = 0; i < formatString.length; i++) {
		c : char = formatString[i];
		if (formatting) {
			switch (c) {
			case '%':
				buf ~= '%';
				break;
			case 'c':
				formatChar(ref buf, ref vl);
				break;
			case 'd':
				formatInt(ref buf, ref vl);
				break;
			case 'f':
				if (_typeids[index].type == Type.F32) {
					formatFloat(ref buf, ref vl);
				} else if (_typeids[index].type == Type.F64) {
					formatDouble(ref buf, ref vl);
				} else {
					throw new Exception("type to %f format mismatch");
				}
				break;
			case 'X':
				formatHex(_typeids[index], ref buf, ref vl);
				break;
			case 'x':
				formatHex(_typeids[index],ref buf, ref vl);
				buf = cast(char[])toLower(cast(string) buf);
				break;
			case 'p':
				formatPointer(ref buf, ref vl);
				break;
			case 's':
				formatType(_typeids[index], ref buf, ref vl);
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
			buf ~= c;
		}
	}
	buf ~= '\0';
	buf = buf[0 .. $-1];  // Disregard the nul when it comes to length.
}

private fn formatNull(ref buf : char[], ref vl : va_list)
{
	buf ~= cast(char[]) "null";
}

private fn formatObject(ref buf : char[], ref vl : va_list)
{
	obj := va_arg!Object(vl);
	if (obj is null) {
		formatNull(ref buf, ref vl);
		return;
	}
	buf ~= cast(char[]) obj.toString();
}

private fn formatString(ref buf : char[], ref vl : va_list)
{
	s := va_arg!char[](vl);
	if (s.length > 1 && s[s.length - 1] == '\0') {
		s = s[0 .. s.length - 1];
	}
	buf ~= s;
}

private fn formatByte(ref buf : char[], ref vl : va_list)
{
	b := va_arg!i8(vl);
	buf ~= cast(char[]) toString(b);
}

private fn formatUbyte(ref buf : char[], ref vl : va_list)
{
	b := va_arg!u8(vl);
	buf ~= cast(char[]) toString(b);
}

private fn formatShort(ref buf : char[], ref vl : va_list)
{
	s := va_arg!i16(vl);
	buf ~= cast(char[]) toString(s);
}

private fn formatUshort(ref buf : char[], ref vl : va_list)
{
	s := va_arg!u16(vl);
	buf ~= cast(char[]) toString(s);
}

private fn formatInt(ref buf : char[], ref vl : va_list)
{
	i := va_arg!i32(vl);
	buf ~= cast(char[]) toString(i);
}

private fn formatUint(ref buf : char[], ref vl : va_list)
{
	i := va_arg!u32(vl);
	buf ~= cast(char[]) toString(i);
}

private fn formatLong(ref buf : char[], ref vl : va_list)
{
	l := va_arg!i64(vl);
	buf ~= cast(char[]) toString(l);
}

private fn formatUlong(ref buf : char[], ref vl : va_list)
{
	l := va_arg!u64(vl);
	buf ~= cast(char[]) toString(l);
}

private fn formatFloat(ref buf : char[], ref vl : va_list)
{
	f := va_arg!f32(vl);
	buf ~= cast(char[]) toString(f);
}

private fn formatDouble(ref buf : char[], ref vl : va_list)
{
	d := va_arg!f64(vl);
	buf ~= cast(char[]) toString(d);
}

private fn formatChar(ref buf : char[], ref vl : va_list)
{
	c := va_arg!char(vl);
	buf ~= c;
}

private fn formatHex(id : TypeInfo, ref buf : char[], ref vl : va_list)
{
	ul : u64;
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
	buf ~= cast(char[])toStringHex(ul);
}

private fn formatPointer(ref buf : char[], ref vl : va_list)
{
	p := va_arg!void*(vl);
	buf ~= cast(char[]) toString(p);
}


private fn formatArray(id : TypeInfo, ref buf : char[], ref vl : va_list)
{
	if (id.base.type == Type.Char) {
		formatString(ref buf, ref vl);
	} else {
		v := va_arg!void[](vl);
		old := vl;
		vl = v.ptr;
		buf ~= cast(char[]) "[";
		foreach (i; 0 .. v.length) {
			if (id.base.type == Type.Char) {
				buf ~= cast(char[]) "\"";
				formatString(ref buf, ref vl);
				buf ~= cast(char[]) "\"";
			} else {
				formatType(id.base, ref buf, ref vl);
			}
			if (i < v.length - 1) {
				buf ~= cast(char[]) ", ";
			}
		}
		vl = old;
		buf ~= cast(char[]) "]";
	}
}

private fn formatType(id : TypeInfo, ref buf : char[], ref vl : va_list)
{
	switch (id.type) {
	case Type.Class:
		formatObject(ref buf, ref vl);
		break;
	case Type.Array:
		formatArray(id, ref buf, ref vl);
		break;
	case Type.Bool:
		formatBool(ref buf, ref vl);
		break;
	case Type.I8:
		formatByte(ref buf, ref vl);
		break;
	case Type.U8:
		formatUbyte(ref buf, ref vl);
		break;
	case Type.I16:
		formatShort(ref buf, ref vl);
		break;
	case Type.U16:
		formatUshort(ref buf, ref vl);
		break;
	case Type.I32:
		formatInt(ref buf, ref vl);
		break;
	case Type.U32:
		formatUint(ref buf, ref vl);
		break;
	case Type.I64:
		formatLong(ref buf, ref vl);
		break;
	case Type.U64:
		formatUlong(ref buf, ref vl);
		break;
	case Type.F32:
		formatFloat(ref buf, ref vl);
		break;
	case Type.F64:
		formatDouble(ref buf, ref vl);
		break;
	case Type.Char:
		formatChar(ref buf, ref vl);
		break;
	case Type.Function, Type.Delegate, Type.Pointer:
		formatPointer(ref buf, ref vl);
		break;
	default:
		throw new Exception(format("Don't know how to print type id %s.", id.type));
	}
}

private fn formatBool(ref buf : char[], ref vl : va_list)
{
	b := va_arg!bool(vl);
	buf ~= cast(char[]) (b ? "true" : "false");
}
