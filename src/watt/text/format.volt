module watt.text.format;

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
			case 'X':
				formatHex(ref buf, ref vl);
				break;
			case 'x':
				formatHex(ref buf, ref vl);
				buf = toLower(cast(string) buf);
				break;
			case 'p':
				formatPointer(ref buf, ref vl);
				break;
			case 's':
				formatType(_typeids[index], ref buf, ref vl);
				break;
			default:
				throw new object.Exception(format("unknown format specifier '%c'", c));
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
	buf.length = buf.length - 1;  // Disregard the nul when it comes to length.
	return;
}

private void formatNull(ref char[] buf, ref va_list vl)
{
	buf ~= cast(char[]) "null";
	return;
}

private void formatObject(ref char[] buf, ref va_list vl)
{
	auto obj = va_arg!object.Object(vl);
	if (obj is null) {
		formatNull(ref buf, ref vl);
		return;
	}
	buf ~= cast(char[]) obj.toString();
	return;
}

private void formatString(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!char[](vl);
	if (s.length > 1 && s[s.length - 1] == '\0') {
		s = s[0 .. s.length - 1];
	}
	buf ~= s;
	return;
}

private void formatByte(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!byte(vl);
	buf ~= cast(char[]) toString(b);
	return;
}

private void formatUbyte(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!ubyte(vl);
	buf ~= cast(char[]) toString(b);
	return;
}

private void formatShort(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!short(vl);
	buf ~= cast(char[]) toString(s);
	return;
}

private void formatUshort(ref char[] buf, ref va_list vl)
{
	auto s = va_arg!ushort(vl);
	buf ~= cast(char[]) toString(s);
	return;
}

private void formatInt(ref char[] buf, ref va_list vl)
{
	auto i = va_arg!int(vl);
	buf ~= cast(char[]) toString(i);
	return;
}

private void formatUint(ref char[] buf, ref va_list vl)
{
	auto i = va_arg!uint(vl);
	buf ~= cast(char[]) toString(i);
	return;
}

private void formatLong(ref char[] buf, ref va_list vl)
{
	auto l = va_arg!long(vl);
	buf ~= cast(char[]) toString(l);
	return;
}

private void formatUlong(ref char[] buf, ref va_list vl)
{
	auto l = va_arg!ulong(vl);
	buf ~= cast(char[]) toString(l);
	return;
}

private void formatChar(ref char[] buf, ref va_list vl)
{
	auto c = va_arg!char(vl);
	buf ~= c;
	return;
}

private void formatHex(ref char[] buf, ref va_list vl)
{
	auto l = va_arg!ulong(vl);
	buf ~= cast(char[]) toStringHex(l);
	return;
}

private void formatPointer(ref char[] buf, ref va_list vl)
{
	auto p = va_arg!void*(vl);
	buf ~= cast(char[]) toString(p);
	return;
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
	return;
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
	case object.TYPE_FUNCTION, object.TYPE_DELEGATE, object.TYPE_POINTER:
		formatPointer(ref buf, ref vl);
		break;
	default:
		throw new object.Exception(format("Don't know how to print type id %s.", id.type));
	}
	return;
}

private void formatBool(ref char[] buf, ref va_list vl)
{
	auto b = va_arg!bool(vl);
	buf ~= cast(char[]) (b ? "true" : "false");
	return;
}



