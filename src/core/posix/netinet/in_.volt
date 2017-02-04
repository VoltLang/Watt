/**
 * D header file for POSIX.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.posix.netinet.in_;

//private import core.sys.posix.config;
//public import core.stdc.inttypes; // for uint32_t, uint16_t, uint8_t
public import core.posix.arpa.inet;
public import core.posix.sys.socket; // for sa_family_t

version (Posix):
extern (C):

//
// Required
//
/*
NOTE: The following must must be defined in core.sys.posix.arpa.inet to break
      a circular import: in_port_t, in_addr_t, struct in_addr, INET_ADDRSTRLEN.

in_port_t
in_addr_t

sa_family_t // from core.sys.posix.sys.socket
uint8_t     // from core.stdc.inttypes
uint32_t    // from core.stdc.inttypes

struct in_addr
{
    in_addr_t   s_addr;
}

struct sockaddr_in
{
    sa_family_t sin_family;
    in_port_t   sin_port;
    in_addr     sin_addr;
}

IPPROTO_IP
IPPROTO_ICMP
IPPROTO_TCP
IPPROTO_UDP

INADDR_ANY
INADDR_BROADCAST

INET_ADDRSTRLEN

htonl() // from core.sys.posix.arpa.inet
htons() // from core.sys.posix.arpa.inet
ntohl() // from core.sys.posix.arpa.inet
ntohs() // from core.sys.posix.arpa.inet
*/

version( Linux )
{
    // Some networking constants are subtly different for glibc, linux kernel
    // constants are also provided below.

    alias in_port_t = u16;
    alias in_addr_t = u32;

    struct in_addr
    {
        in_addr_t s_addr;
    }

    private enum __SOCK_SIZE__ = 16;

    struct sockaddr_in
    {
        sa_family_t sin_family;
        in_port_t   sin_port;
        in_addr     sin_addr;

        /* Pad to size of `struct sockaddr'. */
        ubyte[8] __pad;//__SOCK_SIZE__ - typeid(sa_family_t).size -
              //typeid(in_port_t).size - typeid(in_addr).size] __pad;
    }

    enum
    {
        IPPROTO_IP   = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_IGMP = 2,
        IPPROTO_GGP  = 3,
        IPPROTO_TCP  = 6,
        IPPROTO_PUP  = 12,
        IPPROTO_UDP  = 17,
        IPPROTO_IDP  = 22,
        IPPROTO_ND   = 77,
        IPPROTO_MAX  = 256
    }

    enum : uint
    {
        INADDR_ANY       = 0x00000000,
        INADDR_BROADCAST = 0xffffffffu,
        INADDR_LOOPBACK  = 0x7F000001u,
        INADDR_NONE      = 0xFFFFFFFFu
    }

    //enum INET_ADDRSTRLEN       = 16;
}
else version( OSX )
{
    alias in_port_t = u16;
    alias in_addr_t = u32;

    struct in_addr
    {
        in_addr_t s_addr;
    }

    private enum __SOCK_SIZE__ = 16;

    struct sockaddr_in
    {
        ubyte       sin_len;
        sa_family_t sin_family;
        in_port_t   sin_port;
        in_addr     sin_addr;
        ubyte[8]    sin_zero;
    }

    enum
    {
        IPPROTO_IP   = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_IGMP = 2,
        IPPROTO_GGP  = 3,
        IPPROTO_TCP  = 6,
        IPPROTO_PUP  = 12,
        IPPROTO_UDP  = 17,
        IPPROTO_IDP  = 22,
        IPPROTO_ND   = 77,
        IPPROTO_MAX  = 256
    }

    enum : uint
    {
        INADDR_ANY       = 0x00000000,
        INADDR_BROADCAST = 0xffffffffu,
        INADDR_LOOPBACK  = 0x7F000001u,
        INADDR_NONE      = 0xFFFFFFFFu
    }

    //enum INET_ADDRSTRLEN       = 16;
}

//
// IPV6 (IP6)
//
/*
NOTE: The following must must be defined in core.sys.posix.arpa.inet to break
      a circular import: INET6_ADDRSTRLEN.

struct in6_addr
{
    uint8_t[16] s6_addr;
}

struct sockaddr_in6
{
    sa_family_t sin6_family;
    in_port_t   sin6_port;
    uint32_t    sin6_flowinfo;
    in6_addr    sin6_addr;
    uint32_t    sin6_scope_id;
}

extern in6_addr in6addr_any;
extern in6_addr in6addr_loopback;

struct ipv6_mreq
{
    in6_addr    ipv6mr_multiaddr;
    uint        ipv6mr_interface;
}

IPPROTO_IPV6

INET6_ADDRSTRLEN

IPV6_JOIN_GROUP
IPV6_LEAVE_GROUP
IPV6_MULTICAST_HOPS
IPV6_MULTICAST_IF
IPV6_MULTICAST_LOOP
IPV6_UNICAST_HOPS
IPV6_V6ONLY

// macros
int IN6_IS_ADDR_UNSPECIFIED(in6_addr*)
int IN6_IS_ADDR_LOOPBACK(in6_addr*)
int IN6_IS_ADDR_MULTICAST(in6_addr*)
int IN6_IS_ADDR_LINKLOCAL(in6_addr*)
int IN6_IS_ADDR_SITELOCAL(in6_addr*)
int IN6_IS_ADDR_V4MAPPED(in6_addr*)
int IN6_IS_ADDR_V4COMPAT(in6_addr*)
int IN6_IS_ADDR_MC_NODELOCAL(in6_addr*)
int IN6_IS_ADDR_MC_LINKLOCAL(in6_addr*)
int IN6_IS_ADDR_MC_SITELOCAL(in6_addr*)
int IN6_IS_ADDR_MC_ORGLOCAL(in6_addr*)
int IN6_IS_ADDR_MC_GLOBAL(in6_addr*)
*/

version ( Linux )
{
    struct in6_addr
    {
        union _u
        {
            u8[16] s6_addr;
            u16[8] s6_addr16;
            u32[4] s6_addr32;
        }
        u: _u;
    }

    struct sockaddr_in6
    {
        sa_family_t sin6_family;
        in_port_t   sin6_port;
        u32    sin6_flowinfo;
        in6_addr    sin6_addr;
        u32    sin6_scope_id;
    }

    extern global immutable in6_addr in6addr_any;
    extern global immutable in6_addr in6addr_loopback;

    struct ipv6_mreq
    {
        in6_addr    ipv6mr_multiaddr;
        uint        ipv6mr_interface;
    }

    enum : uint
    {
        IPPROTO_IPV6        = 41U,

        //INET6_ADDRSTRLEN    = 46,

        IPV6_JOIN_GROUP     = 20,
        IPV6_LEAVE_GROUP    = 21,
        IPV6_MULTICAST_HOPS = 18,
        IPV6_MULTICAST_IF   = 17,
        IPV6_MULTICAST_LOOP = 19,
        IPV6_UNICAST_HOPS   = 16,
        IPV6_V6ONLY         = 26
    }

    // macros
    extern (Volt) int IN6_IS_ADDR_UNSPECIFIED( in6_addr* addr )
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == 0 &&
               (cast(u32*) addr)[3] == 0;
    }

    extern (Volt) int IN6_IS_ADDR_LOOPBACK( in6_addr* addr )
    {
        return (cast(u32*) addr)[0] == 0  &&
               (cast(u32*) addr)[1] == 0  &&
               (cast(u32*) addr)[2] == 0  &&
               (cast(u32*) addr)[3] == htonl( 1 );
    }

    extern (Volt) int IN6_IS_ADDR_MULTICAST( in6_addr* addr )
    {
        return (cast(u8*) addr)[0] == 0xff;
    }

    extern (Volt) int IN6_IS_ADDR_LINKLOCAL( in6_addr* addr )
    {
        return ((cast(u32*) addr)[0] & htonl( 0xffc00000u )) == htonl( 0xfe800000u );
    }

    extern (Volt) int IN6_IS_ADDR_SITELOCAL( in6_addr* addr )
    {
        return ((cast(u32*) addr)[0] & htonl( 0xffc00000u )) == htonl( 0xfec00000u );
    }

    extern (Volt) int IN6_IS_ADDR_V4MAPPED( in6_addr* addr )
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == htonl( 0xffff );
    }

    extern (Volt) int IN6_IS_ADDR_V4COMPAT( in6_addr* addr )
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == 0 &&
               ntohl( (cast(u32*) addr)[3] ) > 1;
    }

    extern (Volt) int IN6_IS_ADDR_MC_NODELOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x1;
    }

    extern (Volt) int IN6_IS_ADDR_MC_LINKLOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x2;
    }

    extern (Volt) int IN6_IS_ADDR_MC_SITELOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST(addr) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x5;
    }

    extern (Volt) int IN6_IS_ADDR_MC_ORGLOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x8;
    }

    extern (Volt) int IN6_IS_ADDR_MC_GLOBAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0xe;
    }
}
else version( OSX )
{
    struct in6_addr
    {
        union _u
        {
            u8[16] s6_addr;
            u16[8] s6_addr16;
            u32[4] s6_addr32;
        }
        u: _u;
    }

    struct sockaddr_in6
    {
        u8     sin6_len;
        sa_family_t sin6_family;
        in_port_t   sin6_port;
        u32    sin6_flowinfo;
        in6_addr    sin6_addr;
        u32    sin6_scope_id;
    }

    extern global immutable in6_addr in6addr_any;
    extern global immutable in6_addr in6addr_loopback;

    struct ipv6_mreq
    {
        in6_addr    ipv6mr_multiaddr;
        uint        ipv6mr_interface;
    }

    enum : uint
    {
        IPPROTO_IPV6        = 41u,

        //INET6_ADDRSTRLEN    = 46,

        IPV6_JOIN_GROUP     = 12,
        IPV6_LEAVE_GROUP    = 13,
        IPV6_MULTICAST_HOPS = 10,
        IPV6_MULTICAST_IF   = 9,
        IPV6_MULTICAST_LOOP = 11,
        IPV6_UNICAST_HOPS   = 4,
        IPV6_V6ONLY         = 27
    }

    // macros
    extern (Volt) int IN6_IS_ADDR_UNSPECIFIED( in6_addr* addr )  
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == 0 &&
               (cast(u32*) addr)[3] == 0;
    }

    extern (Volt) int IN6_IS_ADDR_LOOPBACK( in6_addr* addr )  
    {
        return (cast(u32*) addr)[0] == 0  &&
               (cast(u32*) addr)[1] == 0  &&
               (cast(u32*) addr)[2] == 0  &&
               (cast(u32*) addr)[3] == ntohl( 1 );
    }

    extern (Volt) int IN6_IS_ADDR_MULTICAST( in6_addr* addr )  
    {
        return addr.u.s6_addr[0] == 0xff;
    }

    extern (Volt) int IN6_IS_ADDR_LINKLOCAL( in6_addr* addr )  
    {
        return addr.u.s6_addr[0] == 0xfe && (addr.u.s6_addr[1] & 0xc0) == 0x80;
    }

    extern (Volt) int IN6_IS_ADDR_SITELOCAL( in6_addr* addr )  
    {
        return addr.u.s6_addr[0] == 0xfe && (addr.u.s6_addr[1] & 0xc0) == 0xc0;
    }

    extern (Volt) int IN6_IS_ADDR_V4MAPPED( in6_addr* addr )  
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == ntohl( 0x0000ffff );
    }

    extern (Volt) int IN6_IS_ADDR_V4COMPAT( in6_addr* addr )  
    {
        return (cast(u32*) addr)[0] == 0 &&
               (cast(u32*) addr)[1] == 0 &&
               (cast(u32*) addr)[2] == 0 &&
               (cast(u32*) addr)[3] != 0 &&
               (cast(u32*) addr)[3] != ntohl( 1 );
    }

    extern (Volt) int IN6_IS_ADDR_MC_NODELOCAL( in6_addr* addr )  
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x1;
    }

    extern (Volt) int IN6_IS_ADDR_MC_LINKLOCAL( in6_addr* addr )  
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x2;
    }

    extern (Volt) int IN6_IS_ADDR_MC_SITELOCAL( in6_addr* addr )  
    {
        return IN6_IS_ADDR_MULTICAST(addr) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x5;
    }

    extern (Volt) int IN6_IS_ADDR_MC_ORGLOCAL( in6_addr* addr )  
    {
        return IN6_IS_ADDR_MULTICAST( addr) &&
               ((cast(u8*) addr)[1] & 0xf) == 0x8;
    }

    extern (Volt) int IN6_IS_ADDR_MC_GLOBAL( in6_addr* addr )  
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(u8*) addr)[1] & 0xf) == 0xe;
    }
}


//
// Raw Sockets (RS)
//
/*
IPPROTO_RAW
*/

version( Linux )
{
    enum IPPROTO_RAW = 255;
}
else version( OSX )
{
    enum IPPROTO_RAW = 255;
}
