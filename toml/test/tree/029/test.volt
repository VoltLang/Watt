module test;

import toml = watt.toml;

global src := `
# Test file for TOML
# Only this one tries to emulate a TOML file written by a user of the kind of parser writers probably hate
# This part you'll really hate

[the]
test_string = "You'll hate me after this - #"          # " Annoying, isn't it?

    [the.hard]
    test_array = [ "] ", " # "]      # ] There you go, parse this!
    test_array2 = [ "Test #11 ]proved that", "Experiment #9 was a success" ]
    # You didn't think it'd as easy as chucking out the last #, did you?
    another_test_string = " Same thing, but with a string #"
    harder_test_string = " And when \"'s are in the string, along with # \""   # "and comments are there too"
    # Things will get harder

        [the.hard."bit#"]
        "what?" = "You don't think some user won't do that?"
        multi_line_array = [
            "]",
            # ] Oh yes I did
            ]

# Each of the following keygroups/key value pairs should produce an error. Uncomment to them to test

#[error]   if you didn't catch this, your parser is broken
#string = "Anything other than tabs, spaces and newline after a keygroup or key value pair has ended should produce an error unless it is a comment"   like this
#array = [
#         "This might most likely happen in multiline arrays",
#         Like here,
#         "or here,
#         and here"
#         ]     End of array comment, forgot the #
#number = 3.14  pi <--again forgot the #         
`;

fn main(args: string[]) i32
{
	val := toml.parse(src);
	if (val["the"]["test_string"].str() != "You'll hate me after this - #") {
		return 1;
	}
	arr1 := val["the"]["hard"]["test_array"].array();
	if (arr1.length != 2) {
		return 2;
	}
	if (arr1[0].str() != "] ") {
		return 3;
	}
	if (arr1[1].str() != " # ") {
		return 4;
	}
	if (val["the"]["hard"]["bit#"]["what?"].str() != "You don't think some user won't do that?") {
		return 5;
	}
	arr2 := val["the"]["hard"]["bit#"]["multi_line_array"].array();
	if (arr2.length != 1) {
		return 6;
	}
	if (arr2[0].str() != "]") {
		return 7;
	}
	return 0;
}
