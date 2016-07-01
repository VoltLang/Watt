module watt.text.format;

static import object;
import core.exception;
import core.stdc.stdio;
import watt.varargs;
import watt.conv;


string format(const(char)[] formatString, ...)
{
	va_list vl;
	char[] buf;

	va_start(vl);
	formatImpl(formatString, ref _typeids, ref buf, ref vl);
	va_end(vl);
	return cast(string) buf;
}

void formatImpl(const(char)[] formatString, ref object.TypeInfo[] _typeids, ref char[] buf, ref va_list vl)
{
	bool formatting;
	int index;

	for (uint i = 0; i < formatString.length; i++) {
		char c = formatString[i];
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
				if (_typeids[index].type == object.TYPE_FLOAT) {
					formatFloat(ref buf, ref vl);
				} else if (_typeids[index].type == object.TYPE_DOUBLE) {
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

private void formatNull(ref char[] buf, ref va_list vl)
{
	buf ~= cast(char[]) "null";
}

private void formatObject(ref char[] buf, ref va_list vl)
{
	auto obj = va_arg!object.Object(vl);
	if (obj is null) {
		formatNull(ref buf, ref vl);
		return;
	}
	buf ~= cast(char[]) obj.toString();
}

private void formatString(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!char[](vl);
	if (s.length > 1 && s[s.length - 1] == '\0') {
		s = s[0 .. s.length - 1];
	}
	buf ~= s;
}

private void formatByte(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!byte(vl);
	buf ~= cast(char[]) toString(b);
}

private void formatUbyte(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!ubyte(vl);
	buf ~= cast(char[]) toString(b);
}

private void formatShort(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!short(vl);
	buf ~= cast(char[]) toString(s);
}

private void formatUshort(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!ushort(vl);
	buf ~= cast(char[]) toString(s);
}

private void formatInt(ref char[] buf, ref va_list vl)
{
	auto i = va_arg!int(vl);
	buf ~= cast(char[]) toString(i);
}

private void formatUint(ref char[] buf, ref va_list vl)
{
	auto i = va_arg!uint(vl);
	buf ~= cast(char[]) toString(i);
}

private void formatLong(ref char[] buf, ref va_list vl)
{
	auto l = va_arg!long(vl);
	buf ~= cast(char[]) toString(l);
}

private void formatUlong(ref char[] buf, ref va_list vl)
{
	auto l = va_arg!ulong(vl);
	buf ~= cast(char[]) toString(l);
}

private void formatFloat(ref char[] buf, ref va_list vl)
{
	auto f = va_arg!float(vl);
	buf ~= cast(char[]) toString(f);
}

private void formatDouble(ref char[] buf, ref va_list vl)
{
	auto d = va_arg!double(vl);
	buf ~= cast(char[]) toString(d);
}

private void formatChar(ref char[] buf, ref va_list vl)
{
	auto c = va_arg!char(vl);
	buf ~= c;
}

private void formatHex(object.TypeInfo id, ref char[] buf, ref va_list vl)
{
	u64 ul;
	switch (id.type) {
	case object.TYPE_BYTE:
		ul = cast(u64)va_arg!i8(vl);
		break;
	case object.TYPE_UBYTE:
		ul = cast(u64)va_arg!u8(vl);
		break;
	case object.TYPE_SHORT:
		ul = cast(u64)va_arg!i16(vl);
		break;
	case object.TYPE_USHORT:
		ul = cast(u64)va_arg!u16(vl);
		break;
	case object.TYPE_INT:
		ul = cast(u64)va_arg!i32(vl);
		break;
	case object.TYPE_UINT:
		ul = cast(u64)va_arg!u32(vl);
		break;
	case object.TYPE_LONG:
		ul = cast(u64)va_arg!i64(vl);
		break;
	case object.TYPE_ULONG:
		ul = va_arg!u64(vl);
		break;
	default:
		throw new Exception(format("Can't know how to hex-print type id %s.", id.type));
	}
	buf ~= cast(char[])toStringHex(ul);
}

private void formatPointer(ref char[] buf, ref va_list vl)
{
	auto p = va_arg!void*(vl);
	buf ~= cast(char[]) toString(p);
}


private void formatArray(object.TypeInfo id, ref char[] buf, ref va_list vl)
{
	if (id.base.type == object.TYPE_CHAR) {
		formatString(ref buf, ref vl);
	} else {
		auto v = va_arg!void[](vl);
		auto old = vl;
		vl = v.ptr;
		buf ~= cast(char[]) "[";
		for (size_t i = 0; i < v.length; i++) {
			if (id.base.type == object.TYPE_CHAR) {
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

private void formatType(object.TypeInfo id, ref char[] buf, ref va_list vl)
{
	switch (id.type) {
	case object.TYPE_CLASS:
		formatObject(ref buf, ref vl);
		break;
	case object.TYPE_ARRAY:
		formatArray(id, ref buf, ref vl);
		break;
	case object.TYPE_BOOL:
		formatBool(ref buf, ref vl);
		break;
	case object.TYPE_BYTE:
		formatByte(ref buf, ref vl);
		break;
	case object.TYPE_UBYTE:
		formatUbyte(ref buf, ref vl);
		break;
	case object.TYPE_SHORT:
		formatShort(ref buf, ref vl);
		break;
	case object.TYPE_USHORT:
		formatUshort(ref buf, ref vl);
		break;
	case object.TYPE_INT:
		formatInt(ref buf, ref vl);
		break;
	case object.TYPE_UINT:
		formatUint(ref buf, ref vl);
		break;
	case object.TYPE_LONG:
		formatLong(ref buf, ref vl);
		break;
	case object.TYPE_ULONG:
		formatUlong(ref buf, ref vl);
		break;
	case object.TYPE_FLOAT:
		formatFloat(ref buf, ref vl);
		break;
	case object.TYPE_DOUBLE:
		formatDouble(ref buf, ref vl);
		break;
	case object.TYPE_CHAR:
		formatChar(ref buf, ref vl);
		break;
	case object.TYPE_FUNCTION, object.TYPE_DELEGATE, object.TYPE_POINTER:
		formatPointer(ref buf, ref vl);
		break;
	default:
		throw new Exception(format("Don't know how to print type id %s.", id.type));
	}
}

private void formatBool(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!bool(vl);
	buf ~= cast(char[]) (b ? "true" : "false");
}
