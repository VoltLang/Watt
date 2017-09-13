//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global dst := "start:end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink("", tds);
	return tds.result == dst ? 0 : 1;
}
