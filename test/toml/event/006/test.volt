//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
"" = "blank"
'' = 'blank'
`;

global dst := `start:k!("blank"):k!("blank"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
