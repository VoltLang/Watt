//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
winpath  = 'C:\Users\nodejs\templates'
winpath2 = '\\ServerX\admin$\system32\'
quoted   = 'Tom "Dubs" Preston-Werner'
regex    = '<\i\c*\s*>'
`;

global dst := `start:k!winpath("C:\Users\nodejs\templates"):k!winpath2("\\ServerX\admin$\system32\"):k!quoted("Tom "Dubs" Preston-Werner"):k!regex("<\i\c*\s*>"):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
