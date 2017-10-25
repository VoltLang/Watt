//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
int5 = 1_000
int6 = 5_349_221
int7 = 1_2_3_4_5
`;

global dst := "start:k!int5(1000):k!int6(5349221):k!int7(12345):end:";

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
