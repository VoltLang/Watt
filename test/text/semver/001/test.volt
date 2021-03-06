module test;

import watt.text.semver;

fn parseTest()
{
	testStrings := [
		"0.1.0",
		"0.2.0-alpha",
		"0.3.0+linux",
		"1.0.0-rc1+win32",
		"1.2.3+foo-bar",
		"1.2.3-foo-----+bar",
		"1.0.0-alpha.1",
	];
	foreach (ts; testStrings) {
		sv := new Release(ts);
		assert(sv.toString() == ts);
	}
}

fn ensureFailure()
{
	testStrings := [
		"hello world",
		"1。2。4",
		"v1.2.3",
		"一.Ⅱ.山",
		"1.2.3hi",
		"1.3.-4",
		"1.2.3-foo+barの",
		"1.",
		"1.2.",
	];
	foreach (ts; testStrings) {
		retval := Release.isValid(ts);
		assert(!retval);
	}
}

fn testComparison()
{
	// This list should be in ascending order.
	testSemVers := [
		new Release("1.0.0-alpha"),
		new Release("1.0.0-alpha.1"),
		new Release("1.0.0-alpha.beta"),
		new Release("1.0.0-beta"),
		new Release("1.0.0-beta.2"),
		new Release("1.0.0-beta.11"),
		new Release("1.0.0-rc.1"),
		new Release("1.0.0"),
		new Release("1.1.0"),
		new Release("1.1.1"),
		new Release("2.0.0"),
	];

	i: size_t = 0;
	while (i < testSemVers.length - 1) {
		retval := testSemVers[i] < testSemVers[i+1];
		assert(retval);
		i++;
	}
	sva := new Release("1.0.0+blah");
	svb := new Release("1.0.0+blam");
	assert(sva == svb);
}

fn main() i32
{
	parseTest();
	ensureFailure();
	testComparison();
	return 0;
}
