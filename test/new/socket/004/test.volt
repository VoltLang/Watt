module test;

import core.object;
import watt.net.socket;

fn main() i32
{
	addr1 := new InternetAddress("127.0.0.1", 80);
	addr2 := new InternetAddress("127.0.0.2", 80);

	assert(addr1.opEquals(addr1));
	assert(!addr1.opEquals(addr2));
	return 0;
}
