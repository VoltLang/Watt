//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
flt1 = +1.0
flt2 = 3.1415
flt3 = -0.01
flt4 = 5e+2
flt5 = -2E-2
flt7 = 6.626e-34
flt8 = 9_224_617.445_991_228_313
`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	/* No test for the output here because the sheer number of variables 
	 * makes getting the exact output right for all platforms a pain.
	 * Just make sure it parses.
	 */
	return 0;
}
