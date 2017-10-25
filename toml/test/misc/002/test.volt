module test;

import toml = watt.toml;

enum src = `
strkey = "string"
intkey = 3
fltkey = 3.1415926538
blnkey = false
arrkey = [1, 2, 3]
tblkey = { key = "value" }
`;

fn main() i32
{
	val := toml.parse(src);
	if (val["strkey"].str() != "string" ||
		val["intkey"].integer() != 3 ||
		val["fltkey"].floating() <= 3 ||
		val["blnkey"].boolean() ||
		val["arrkey"].array()[1].integer() != 2 ||
		val["tblkey"]["key"].str() != "value") {
		return 1;
	}
	val["strkey"].str("hello");
	val["intkey"].integer(6);
	val["fltkey"].floating(-3.1);
	val["blnkey"].boolean(true);

	a := val["arrkey"].array()[0];
	b := new toml.Value(32);
	c := val["arrkey"].array()[2];
	assert(a.type == b.type);
	assert(b.type == c.type);
	assert(c.type == a.type);
	val["arrkey"].array([a, b, c]);

	val["tblkey"].removeKey("key");
	val["tblkey"].tableEntry("key2", new toml.Value(true));

	if (val["strkey"].str() != "hello" ||
		val["intkey"].integer() != 6 ||
		val["fltkey"].floating() >= 3 ||
		!val["blnkey"].boolean() ||
		val["arrkey"].array()[1].integer() != 32 ||
		val["tblkey"].hasKey("key") ||
		!val["tblkey"]["key2"].boolean()) {
		return 2;
	}

	return 0;
}
