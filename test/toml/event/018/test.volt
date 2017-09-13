//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
[[tarray]]
key = "value"
[[tarray]]
key2 = "value"
`;

global dst := `start:tarray!tarray:k!key("value"):tarray!tarray:k!key2("value"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
