//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
[table1]
key = "value"
[table2]
key = "value"
`;

global dst := "start:tstart!table1:k!key(\"value\"):tend!table1:tstart!table2:k!key(\"value\"):tend!table2:end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
