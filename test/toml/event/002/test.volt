//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global dst := `start:k!test("hello"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink("test = \"hello\"", tds);
	return tds.result == dst ? 0 : 1;
}
