//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
str1 = """
Roses are red
Violets are blue"""
`;

global dst := `start:k!str1("Roses are red
Violets are blue"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
