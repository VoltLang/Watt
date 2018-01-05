module test;

import watt.text.getopt;

fn main() i32
{
	emptyArguments: string[];
	boolValue: bool;
	retval := getopt(ref emptyArguments, "d|debug", ref boolValue);
	if (retval || boolValue || emptyArguments !is null) {
		return 1;
	}

	argumentsButNoHits := ["a.out", "debug"];
	retval = getopt(ref argumentsButNoHits, "d|debug", ref boolValue);
	if (retval || boolValue || argumentsButNoHits != ["a.out", "debug"]) {
		return 2;
	}

	argumentsHit := ["b", "c", "--debug"];
	retval = getopt(ref argumentsHit, "d|debug", ref boolValue);
	if (!retval || !boolValue || argumentsHit != ["b", "c"]) {
		return 3;
	}

	argumentsHits := ["a", "--debug", "b", "-d", "c", "--debug"];
	retval = getopt(ref argumentsHits, "d|debug", ref boolValue);
	if (!retval || !boolValue || argumentsHits != ["a", "b", "c"]) {
		return 4;
	}

	shouldBeUnchanged := ["-debug"];
	retval = getopt(ref shouldBeUnchanged, "d|debug", ref boolValue);
	if (retval || boolValue || shouldBeUnchanged != ["-debug"]) {
		return 5;
	}

	return 0;
}
