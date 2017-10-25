//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
name = { first = "Tom", last = "Preston-Werner" }
point = { x = 1, y = 2 }
`;

global dst := "start:k!name(table{k!first(\"Tom\"):k!last(\"Preston-Werner\"):}:):k!point(table{k!x(1):k!y(2):}:):end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
