module test;

import toml = watt.toml;

global src := `
[a]
the = "key"
[a.b]
this = "is still valid"  
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["a"]["the"].str() != "key") {
		return 1;
	}
	if (val["a"]["b"]["this"].str() != "is still valid") {
		return 2;
	}
	return 0;
}
