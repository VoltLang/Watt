module tomldebug;

import watt.toml.event;

public import watt.io;

class TomlDebugSink : NullEventSink
{
	result: string;

	override fn start() { result ~= "start:"; }
	override fn end() { result ~= "end:"; }

	override fn commentStart() { result ~= "#"; }
	override fn commentEnd() { result ~= "#:"; }
	override fn keyValueStart(key: string) { result ~= new "k!${key}("; }
	override fn keyValueEnd(key: string) { result ~= "):"; }
	override fn tableStart(tableName: string) { result ~= new "tstart!${tableName}:"; }
	override fn tableEnd(tableName: string) { result ~= new "tend!${tableName}:"; }
	override fn inlineTableStart() { result ~= "table{"; }
	override fn inlineTableEnd() { result ~= "}:"; }
	override fn tableArray(name: string) { result ~= new "tarray!${name}:"; }

	override fn arrayStart() { result ~= "["; }
	override fn arrayEnd() { result ~= "]"; }

	override fn stringContent(str: string) { result ~= new "\"${str}\""; }
	override fn integerContent(i: i64) { result ~= new "${i}"; }
	override fn floatContent(n: f64) { result ~= new "${n}"; }
	override fn boolContent(b: bool) { result ~= new "${b}"; }
}
