module test;

import watt.net.socket;

fn main() i32
{
    aisNumHost: AddressInfoSearcher;
    aisNumHost.addHint(AddressInfoFlags.NUMERICHOST);

    // Parsing IPv4
    results := aisNumHost.get("127.0.0.1");
    assert(results.length && results[0].family == AddressFamily.INET);

    // Parsing IPv6
    results = aisNumHost.get("::1");
    assert(results.length && results[0].family == AddressFamily.INET6);

    aisFromHell: AddressInfoSearcher;
    aisFromHell.addHint("1234");
    aisFromHell.addHint(AddressInfoFlags.PASSIVE);
    aisFromHell.addHint(SocketType.STREAM);
    aisFromHell.addHint(ProtocolType.TCP);
    aisFromHell.addHint(AddressFamily.INET);
    results = aisFromHell.get(null);
    assert(results.length == 1 && results[0].address.toString() == "0.0.0.0:1234");

    return 0;
}
