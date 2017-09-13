//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
bool1 = true
bool2 = false
`;

global dst := "start:k!bool1(true):k!bool2(false):end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
