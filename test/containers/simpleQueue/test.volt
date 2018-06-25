module main;

import watt.io;
import watt.containers.queue;

struct IntegerQueue = mixin Queue!i32;

fn verifyQueue(q: IntegerQueue, arr: i32[]) bool
{
	return q.length == arr.length && arr == q.borrowUnsafe();
}

fn main() i32
{
	q: IntegerQueue;
	if (!verifyQueue(q, null)) {
		return 1;
	}

	q.enqueue(73);
	if (!verifyQueue(q, [73]) || q.peek() != 73) {
		return 2;
	}
	val := q.dequeue();
	if (val != 73) {
		return 3;
	}
	if (!verifyQueue(q, null)) {
		return 4;
	}


	q.enqueue(41);
	q.enqueue(31);
	q.enqueue(21);
	if (!verifyQueue(q, [21, 31, 41]) || q.peek() != 41) {
		return 5;
	}
	if (q.dequeue() != 41) {
		return 6;
	}
	if (q.dequeue() != 31) {
		return 7;
	}
	if (q.dequeue() != 21) {
		return 8;
	}
	if (!verifyQueue(q, null)) {
		return 9;
	}

	q.clear();
	if (!verifyQueue(q, null)) {
		return 10;
	}

	q.enqueue(17384);
	foreach (i: i32; 0 .. 1024) {
		q.enqueue(i);
		if (q.peek() != 17384) {
			return 11;
		}
	}

	if (q.dequeue() != 17384) {
		return 12;
	}
	i := 0;
	while (i != 1024) {
		if (q.dequeue() != i++) {
			return 13;
		}
	}

	if (!verifyQueue(q, null)) {
		return 14;
	}

	return 0;
}
