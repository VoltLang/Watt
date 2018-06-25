module main;

import watt.containers.stack;

struct IntegerStack = mixin Stack!i32;

fn verifyStack(s: IntegerStack, arr: i32[]) bool
{
	return s.length == arr.length && arr == s.borrowUnsafe();
}

fn main() i32
{
	s: IntegerStack;
	if (!verifyStack(s, null)) {
		return 1;
	}

	s.push(73);
	if (!verifyStack(s, [73]) || s.peek() != 73) {
		return 2;
	}
	val := s.pop();
	if (val != 73) {
		return 3;
	}
	if (!verifyStack(s, null)) {
		return 4;
	}


	s.push(41);
	s.push(31);
	s.push(21);
	if (!verifyStack(s, [41, 31, 21]) || s.peek() != 21) {
		return 5;
	}
	if (s.pop() != 21) {
		return 6;
	}
	if (s.pop() != 31) {
		return 7;
	}
	if (s.pop() != 41) {
		return 8;
	}
	if (!verifyStack(s, null)) {
		return 9;
	}

	s.clear();
	if (!verifyStack(s, null)) {
		return 10;
	}

	s.push(17384);
	foreach (i: i32; 0 .. 1024) {
		s.push(i);
		if (s.peek() != i) {
			return 11;
		}
	}

	i := 1023;
	while (i != -1) {
		if (s.pop() != i--) {
			return 13;
		}
	}
	if (s.pop() != 17384) {
		return 12;
	}

	if (!verifyStack(s, null)) {
		return 14;
	}

	return 0;
}
