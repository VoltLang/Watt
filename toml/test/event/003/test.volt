//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
# COMMENT
key = "value"
`;

global dst := `start:#" COMMENT"#:k!key("value"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
