module test;

import watt.text.getopt;

fn main() i32
{
	emptyArgumentArray: string[];
	stringResult: string;
	retval := getopt(ref emptyArgumentArray, "a|arg", ref stringResult);
	if (retval || emptyArgumentArray.length != 0 || stringResult !is null) {
		return 1;
	}

	argumentArrayWithNoHits := ["a.out", "--file", "./bin/db.bin", "arg"];
	retval = getopt(ref argumentArrayWithNoHits, "a|arg", ref stringResult);
	if (retval || argumentArrayWithNoHits.length != 4 || stringResult !is null) {
		return 2;
	}

	argumentArrayWithHit := ["a.out", "--arg", "0xdeadcafe", "--file", "dummy"];
	retval = getopt(ref argumentArrayWithHit, "a|arg", ref stringResult);
	if (!retval || argumentArrayWithHit.length != 3 || stringResult != "0xdeadcafe") {
		return 3;
	}

	argumentArrayWithHits := ["a.out", "--arg", "abc", "-a", "abc def", "--dummy"];
	retval = getopt(ref argumentArrayWithHits, "a|arg", ref stringResult);
	if (!retval || argumentArrayWithHits != ["a.out", "--dummy"] || stringResult != "abc def") {
		return 4;
	}

	combinedArgument := ["-jhello", "world"];
	retval = getopt(ref combinedArgument, "j|junk", ref stringResult);
	if (!retval || combinedArgument != ["world"] || stringResult != "hello") {
		return 5;
	}

	return 0;
}
