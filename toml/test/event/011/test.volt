//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
regex2 = '''I [dw]on't need \d{2} apples'''
lines  = '''
The first newline is
trimmed in raw strings.'''
`;

global dst :=
`start:k!regex2("I [dw]on't need \d{2} apples"):k!lines("The first newline is
trimmed in raw strings."):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
