module test;

import io = watt.io;

import watt.text.vdoc;
import watt.markdown;
import watt.text.diff;

enum expect1 = 
`
Foo.

Side-effects:
  - Puts all the other fields into known good states.
`;

enum expect2 = `Blarg blarg blarg.`;


enum c1 =
`*!
	 * Foo.
	 *
	 * Side-effects:
	 *   - Puts all the other fields into known good states.
`;

enum c2 =
`/!<
	//! Foo.
	//!
	//! Side-effects:
	//!   - Puts all the other fields into known good states.
`;

enum c3 = `/!< Blarg blarg blarg.`;

enum c4 = `/! Blarg blarg blarg.`;

fn test(name: string, comment: string, expect: string, back: bool) bool
{
	ok := true;
	retBack: bool;
	retClean := cleanComment(comment, out retBack);

	if (retClean != expect) {
		io.error.writefln("differs: %s", name);
		io.error.flush();
		diff(retClean, expect);
		ok = false;
	}

	if (retBack != back) {
		io.error.writefln("back differs: %s", name);
		io.error.flush();
		ok = false;
	}

	return ok;
}

fn main() i32
{
	fail := !test("clean1", c1, expect1, false) ||
	        !test("clean2", c2, expect1, true) ||
	        !test("clean3", c3, expect2, true) ||
	        !test("clean4", c4, expect2, false);

	return fail ? 1 : 0;
}
