module test;

import watt.io;
import core.rt.gc;
import core.rt.aa;

union U
{
	table: Value[string];
}

class Value
{
	a: i8;  // This has to be present, despite being unused.
	mUnion: U;
}

fn foo(u: U*)
{
	writefln("%s", typeid(u.table).size);
	ptr := cast(u8*)allocDg(typeid(u8), 33);
	//buf := new u8[](33);
//	buf := cast(u8[])
	for (i: size_t = 0; i < u.table.keys.length; ++i) {
		k := u.table.keys[i];
		writefln("%s", k);
		v := u.table.values[i];
		if (k[0] == 'T') {
			foo(&v.mUnion);
		}
	}
}

fn main() i32
{
	a := cast(Value)allocDg(typeid(Value), cast(size_t)-1);
	a.mUnion.table["Sk0"] = null;

	b := cast(Value)allocDg(typeid(Value), cast(size_t)-1);

	val := cast(Value)allocDg(typeid(Value), cast(size_t)-1);
	val.mUnion.table["Sk3"] = null;
	val.mUnion.table["T0"] = a;
	val.mUnion.table["T1"] = b;

	foo(&val.mUnion);
	return 0;
}
