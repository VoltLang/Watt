module test;

import watt.io;
import watt.net.socket;

fn main() i32
{
	serv := new Service();
	if (serv.getServiceByName("epmap", "tcp")) {
		assert(serv.name == "loc-srv" || serv.name == "epmap");
		assert(serv.port == 135);
		assert(serv.protocolName == "tcp");
	}
	return 0;
}

