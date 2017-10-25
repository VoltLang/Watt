//T macro:import
module test;

import watt.toml.event;

import tomldebug;

global src := `
str1 = "The quick brown fox jumps over the lazy dog."

str2 = """
The quick brown \


  fox jumps over \
    the lazy dog."""

str3 = """\
       The quick brown \
       fox jumps over \
       the lazy dog.\
       """
`;

global dst := `start:k!str1("The quick brown fox jumps over the lazy dog."):k!str2("The quick brown fox jumps over the lazy dog."):k!str3("The quick brown fox jumps over the lazy dog."):end:`;

fn main() i32
{
	tds := new TomlDebugSink();
	runEventSink(src, tds);
	return tds.result == dst ? 0 : 1;
}
