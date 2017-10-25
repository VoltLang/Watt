//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
int1 = +99
int2 = 42
int3 = 0
int4 = -17
`;

global dst := "start:k!int1(99):k!int2(42):k!int3(0):k!int4(-17):end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
