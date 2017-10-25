//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
str = "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."
`;

global dst := "start:k!str(\"I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF.\"):end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
