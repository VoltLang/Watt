//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
"127.0.0.1" = "value"
'quoted "value"' = "value"
`;

global dst := `start:k!127.0.0.1("value"):k!quoted "value"("value"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
