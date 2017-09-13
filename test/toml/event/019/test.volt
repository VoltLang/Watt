//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
arr = [1, 2, 3]
points = [ { x = 1, y = 2, z = 3 },
           { x = 7, y = 8, z = 9 },
           { x = 2, y = 4, z = 8 } ]
`;

global dst := `start:k!arr([123]):k!points([table{k!x(1):k!y(2):k!z(3):}:table{k!x(7):k!y(8):k!z(9):}:table{k!x(2):k!y(4):k!z(8):}:]):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
