module test;

import watt.net.socket;

fn main() i32
{
	proto := new Protocol();
	assert(proto.getProtocolByType(ProtocolType.TCP));
	assert(proto.name == "tcp");
	assert(proto.aliases.length == 1 && proto.aliases[0] == "TCP");
	return 0;
}

