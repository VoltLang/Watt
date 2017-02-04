module test;

import watt.net.socket;

fn main() i32
{
	data: u8[] = [1, 2, 3, 4];
    auto pair = socketPair();
    scope(exit) foreach (s; pair) s.close();

    pair[0].send(cast(void[])data);

    auto buf = new u8[](data.length);
    pair[1].receive(cast(void[])buf);
    assert(buf == data);
	return 0;
}
