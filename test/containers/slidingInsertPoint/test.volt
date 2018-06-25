module main;

import watt.containers.queue;

struct TheQueue = mixin Queue!i32;

fn main() i32
{
	q: TheQueue;
	foreach (i; 0 .. 1024) {
		q.enqueue(cast(i32)q.length);
		q.dequeue();
	}
	return 0;
}
