//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
bare_key = "value"
bare-key = "value"
1234 = "value"
`;

global dst := `start:k!bare_key("value"):k!bare-key("value"):k!1234("value"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
