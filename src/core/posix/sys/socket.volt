/**
 * From the D header file for POSIX.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly, Alex Rønne Petersen
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.posix.sys.socket;



import core.c.config;
import core.posix.sys.uio;

version (Posix):
extern (C) /*nothrow @nogc*/:

//
// Required
//
/*
socklen_t
sa_family_t

struct sockaddr
{
    sa_family_t sa_family;
    char        sa_data[];
}

struct sockaddr_storage
{
    sa_family_t ss_family;
}

struct msghdr
{
    void*         msg_name;
    socklen_t     msg_namelen;
    struct iovec* msg_iov;
    int           msg_iovlen;
    void*         msg_control;
    socklen_t     msg_controllen;
    int           msg_flags;
}

struct iovec {} // from core.sys.posix.sys.uio

struct cmsghdr
{
    socklen_t cmsg_len;
    int       cmsg_level;
    int       cmsg_type;
}

SCM_RIGHTS

CMSG_DATA(cmsg)
CMSG_NXTHDR(mhdr,cmsg)
CMSG_FIRSTHDR(mhdr)

struct linger
{
    int l_onoff;
    int l_linger;
}

SOCK_DGRAM
SOCK_SEQPACKET
SOCK_STREAM

SOL_SOCKET

SO_ACCEPTCONN
SO_BROADCAST
SO_DEBUG
SO_DONTROUTE
SO_ERROR
SO_KEEPALIVE
SO_LINGER
SO_OOBINLINE
SO_RCVBUF
SO_RCVLOWAT
SO_RCVTIMEO
SO_REUSEADDR
SO_SNDBUF
SO_SNDLOWAT
SO_SNDTIMEO
SO_TYPE

SOMAXCONN

MSG_CTRUNC
MSG_DONTROUTE
MSG_EOR
MSG_OOB
MSG_PEEK
MSG_TRUNC
MSG_WAITALL

AF_INET
AF_UNIX
AF_UNSPEC

SHUT_RD
SHUT_RDWR
SHUT_WR

int     accept(int, sockaddr*, socklen_t*);
int     bind(int, in sockaddr*, socklen_t);
int     connect(int, in sockaddr*, socklen_t);
int     getpeername(int, sockaddr*, socklen_t*);
int     getsockname(int, sockaddr*, socklen_t*);
int     getsockopt(int, int, int, void*, socklen_t*);
int     listen(int, int);
ssize_t recv(int, void*, size_t, int);
ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
ssize_t recvmsg(int, msghdr*, int);
ssize_t send(int, in void*, size_t, int);
ssize_t sendmsg(int, in msghdr*, int);
ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
int     setsockopt(int, int, int, in void*, socklen_t);
int     shutdown(int, int);
int     socket(int, int, int);
int     sockatmark(int);
int     socketpair(int, int, int, ref int[2]);
*/

version( Linux )
{
    // Some of the constants below and from the Bionic section are really from
    // the linux kernel headers.
    alias socklen_t = u32;
    alias sa_family_t = u16;

    struct sockaddr
    {
        sa_family: sa_family_t;
        sa_data: i8[14];
    }

    private enum : size_t
    {
        _SS_SIZE    = 128,
        _SS_PADSIZE = 112 //_SS_SIZE - (typeid(c_ulong).size * 2)
    }

    struct sockaddr_storage
    {
        ss_family: sa_family_t;
        __ss_align: c_ulong;
        __ss_padding: i8[_SS_PADSIZE];
    }

    struct msghdr
    {
        msg_name: void*;
        msg_namelen: socklen_t;
        msg_iov: iovec*;
        msg_iovlen: size_t;
        msg_control: void*;
        msg_controllen: size_t;
        msg_flags: i32;
    }

    struct cmsghdr
    {
        cmsg_len: size_t;
        cmsg_level: i32;
        cmsg_type: i32;
        /+
        static if( false /* (!is( __STRICT_ANSI__ ) && __GNUC__ >= 2) || __STDC_VERSION__ >= 199901L */ )
        {
            ubyte[1] __cmsg_data;
        }+/
    }

    enum : u32
    {
        SCM_RIGHTS = 0x01
    }
/+
    static if( false /* (!is( __STRICT_ANSI__ ) && __GNUC__ >= 2) || __STDC_VERSION__ >= 199901L */ )
    {
        extern (D) ubyte[1] CMSG_DATA( cmsghdr* cmsg ) pure nothrow @nogc { return cmsg.__cmsg_data; }
    }
    else
    {
        extern (D) inout(ubyte)*   CMSG_DATA( inout(cmsghdr)* cmsg ) pure nothrow @nogc { return cast(ubyte*)( cmsg + 1 ); }
    }

    private inout(cmsghdr)* __cmsg_nxthdr(inout(msghdr)*, inout(cmsghdr)*) pure nothrow @nogc;
    extern (D)  inout(cmsghdr)* CMSG_NXTHDR(inout(msghdr)* msg, inout(cmsghdr)* cmsg) pure nothrow @nogc
    {
        return __cmsg_nxthdr(msg, cmsg);
    }

    extern (D) inout(cmsghdr)* CMSG_FIRSTHDR( inout(msghdr)* mhdr ) pure nothrow @nogc
    {
        return ( cast(size_t)mhdr.msg_controllen >= cmsghdr.sizeof
                             ? cast(inout(cmsghdr)*) mhdr.msg_control
                             : cast(inout(cmsghdr)*) null );
    }

    extern (D)
    {
        size_t CMSG_ALIGN( size_t len ) pure nothrow @nogc
        {
            return (len + size_t.sizeof - 1) & cast(size_t) (~(size_t.sizeof - 1));
        }

        size_t CMSG_LEN( size_t len ) pure nothrow @nogc
        {
            return CMSG_ALIGN(cmsghdr.sizeof) + len;
        }
    }

    extern (D) size_t CMSG_SPACE(size_t len) pure nothrow @nogc
    {
        return CMSG_ALIGN(len) + CMSG_ALIGN(cmsghdr.sizeof);
    }
+/
    struct linger
    {
        l_onoff: i32;
        l_linger: i32;
    }

    version (X86)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 18,
            SO_RCVTIMEO     = 20,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 19,
            SO_SNDTIMEO     = 21,
            SO_TYPE         = 3
        }
    }
    else version (X86_64)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 18,
            SO_RCVTIMEO     = 20,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 19,
            SO_SNDTIMEO     = 21,
            SO_TYPE         = 3
        }
    }
    else version (MIPS32)
    {
        enum
        {
            SOCK_DGRAM      = 1,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 2,
        }

        enum
        {
            SOL_SOCKET      = 0xffff
        }

        enum
        {
            SO_ACCEPTCONN   = 0x1009,
            SO_BROADCAST    = 0x0020,
            SO_DEBUG        = 0x0001,
            SO_DONTROUTE    = 0x0010,
            SO_ERROR        = 0x1007,
            SO_KEEPALIVE    = 0x0008,
            SO_LINGER       = 0x0080,
            SO_OOBINLINE    = 0x0100,
            SO_RCVBUF       = 0x1002,
            SO_RCVLOWAT     = 0x1004,
            SO_RCVTIMEO     = 0x1006,
            SO_REUSEADDR    = 0x0004,
            SO_SNDBUF       = 0x1001,
            SO_SNDLOWAT     = 0x1003,
            SO_SNDTIMEO     = 0x1005,
            SO_TYPE         = 0x1008,
        }
    }
    else version (MIPS64)
    {
        enum
        {
            SOCK_DGRAM      = 1,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 2,
        }

        enum
        {
            SOL_SOCKET      = 0xffff
        }

        enum
        {
            SO_ACCEPTCONN   = 0x1009,
            SO_BROADCAST    = 0x0020,
            SO_DEBUG        = 0x0001,
            SO_DONTROUTE    = 0x0010,
            SO_ERROR        = 0x1007,
            SO_KEEPALIVE    = 0x0008,
            SO_LINGER       = 0x0080,
            SO_OOBINLINE    = 0x0100,
            SO_RCVBUF       = 0x1002,
            SO_RCVLOWAT     = 0x1004,
            SO_RCVTIMEO     = 0x1006,
            SO_REUSEADDR    = 0x0004,
            SO_SNDBUF       = 0x1001,
            SO_SNDLOWAT     = 0x1003,
            SO_SNDTIMEO     = 0x1005,
            SO_TYPE         = 0x1008,
        }
    }
    else version (PPC)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 16,
            SO_RCVTIMEO     = 18,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 17,
            SO_SNDTIMEO     = 19,
            SO_TYPE         = 3
        }
    }
    else version (PPC64)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 16,
            SO_RCVTIMEO     = 18,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 17,
            SO_SNDTIMEO     = 19,
            SO_TYPE         = 3
        }
    }
    else version (AArch64)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 18,
            SO_RCVTIMEO     = 20,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 19,
            SO_SNDTIMEO     = 21,
            SO_TYPE         = 3
        }
    }
    else version (ARM)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 18,
            SO_RCVTIMEO     = 20,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 19,
            SO_SNDTIMEO     = 21,
            SO_TYPE         = 3
        }
    }
    else version (SystemZ)
    {
        enum
        {
            SOCK_DGRAM      = 2,
            SOCK_SEQPACKET  = 5,
            SOCK_STREAM     = 1
        }

        enum
        {
            SOL_SOCKET      = 1
        }

        enum
        {
            SO_ACCEPTCONN   = 30,
            SO_BROADCAST    = 6,
            SO_DEBUG        = 1,
            SO_DONTROUTE    = 5,
            SO_ERROR        = 4,
            SO_KEEPALIVE    = 9,
            SO_LINGER       = 13,
            SO_OOBINLINE    = 10,
            SO_RCVBUF       = 8,
            SO_RCVLOWAT     = 18,
            SO_RCVTIMEO     = 20,
            SO_REUSEADDR    = 2,
            SO_SNDBUF       = 7,
            SO_SNDLOWAT     = 19,
            SO_SNDTIMEO     = 21,
            SO_TYPE         = 3
        }
    }
    else
        static assert(false, "unimplemented");

    enum
    {
        SOMAXCONN       = 128
    }

    enum : uint
    {
        MSG_CTRUNC      = 0x08,
        MSG_DONTROUTE   = 0x04,
        MSG_EOR         = 0x80,
        MSG_OOB         = 0x01,
        MSG_PEEK        = 0x02,
        MSG_TRUNC       = 0x20,
        MSG_WAITALL     = 0x100,
        MSG_NOSIGNAL    = 0x4000
    }

    enum
    {
        AF_APPLETALK    = 5,
        AF_INET         = 2,
        AF_IPX          = 4,
        AF_UNIX         = 1,
        AF_UNSPEC       = 0,
        PF_APPLETALK    = AF_APPLETALK,
        PF_IPX          = AF_IPX
    }

    enum int SOCK_RDM   = 4;

    enum
    {
        SHUT_RD,
        SHUT_WR,
        SHUT_RDWR
    }

    int     accept(int, sockaddr*, socklen_t*);
    int     bind(int, in sockaddr*, socklen_t);
    int     connect(int, in sockaddr*, socklen_t);
    int     getpeername(int, sockaddr*, socklen_t*);
    int     getsockname(int, sockaddr*, socklen_t*);
    int     getsockopt(int, int, int, void*, socklen_t*);
    int     listen(int, int);
    ssize_t recv(int, void*, size_t, int);
    ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
    ssize_t recvmsg(int, msghdr*, int);
    ssize_t send(int, in void*, size_t, int);
    ssize_t sendmsg(int, in msghdr*, int);
    ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
    int     setsockopt(int, int, int, in void*, socklen_t);
    int     shutdown(int, int);
    int     socket(int, int, int);
    int     sockatmark(int);
    int     socketpair(int, int, int, ref int[2]);
}
else version( OSX )
{
    alias socklen_t = u32;
    alias sa_family_t = u8;

    struct sockaddr
    {
        sa_len: u8;
        sa_family: sa_family_t;
        sa_data: i8[14];
    }

    private enum : size_t
    {
        _SS_PAD1    = 6,//typeid(i64).size - typeid(i8).size - typeid(sa_family_t).size,
        _SS_PAD2    = 119//128 - typeid(u8).size - typeid(sa_family_t).size - _SS_PAD1 - typeid(i8).size
    }

    struct sockaddr_storage
    {
         ss_len: u8;
         ss_family: sa_family_t;
         __ss_Pad1: i8[_SS_PAD1];
         __ss_align: i64;
         __ss_pad2: i8[_SS_PAD2];
    }

    struct msghdr
    {
        msg_name: void*;
        msg_namelen: socklen_t;
        msg_iov: iovec*;
        msg_iovlen: i32;
        msg_control: void*;
        msg_controllen: socklen_t;
        msg_flags: i32;
    }

    struct cmsghdr
    {
         cmsg_len: socklen_t;
         cmsg_level: i32;
         cmsg_type: i32;
    }

    enum : u32
    {
        SCM_RIGHTS = 0x01
    }

    /+
    CMSG_DATA(cmsg)     ((unsigned char *)(cmsg) + \
                         ALIGN(sizeof(struct cmsghdr)))
    CMSG_NXTHDR(mhdr, cmsg) \
                        (((unsigned char *)(cmsg) + ALIGN((cmsg)->cmsg_len) + \
                         ALIGN(sizeof(struct cmsghdr)) > \
                         (unsigned char *)(mhdr)->msg_control +(mhdr)->msg_controllen) ? \
                         (struct cmsghdr *)0 /* NULL */ : \
                         (struct cmsghdr *)((unsigned char *)(cmsg) + ALIGN((cmsg)->cmsg_len)))
    CMSG_FIRSTHDR(mhdr) ((struct cmsghdr *)(mhdr)->msg_control)
    +/

    struct linger
    {
        l_onoff: i32;
        l_linger: i32;
    }

    enum
    {
        SOCK_DGRAM      = 2,
        SOCK_RDM        = 4,
        SOCK_SEQPACKET  = 5,
        SOCK_STREAM     = 1
    }

    enum : uint
    {
        SOL_SOCKET      = 0xffff
    }

    enum : uint
    {
        SO_ACCEPTCONN   = 0x0002,
        SO_BROADCAST    = 0x0020,
        SO_DEBUG        = 0x0001,
        SO_DONTROUTE    = 0x0010,
        SO_ERROR        = 0x1007,
        SO_KEEPALIVE    = 0x0008,
        SO_LINGER       = 0x1080,
        SO_NOSIGPIPE    = 0x1022, // non-standard
        SO_OOBINLINE    = 0x0100,
        SO_RCVBUF       = 0x1002,
        SO_RCVLOWAT     = 0x1004,
        SO_RCVTIMEO     = 0x1006,
        SO_REUSEADDR    = 0x0004,
        SO_SNDBUF       = 0x1001,
        SO_SNDLOWAT     = 0x1003,
        SO_SNDTIMEO     = 0x1005,
        SO_TYPE         = 0x1008
    }

    enum
    {
        SOMAXCONN       = 128
    }

    enum : uint
    {
        MSG_CTRUNC      = 0x20,
        MSG_DONTROUTE   = 0x4,
        MSG_EOR         = 0x8,
        MSG_OOB         = 0x1,
        MSG_PEEK        = 0x2,
        MSG_TRUNC       = 0x10,
        MSG_WAITALL     = 0x40
    }

    enum
    {
        AF_APPLETALK    = 16,
        AF_INET         = 2,
        AF_IPX          = 23,
        AF_UNIX         = 1,
        AF_UNSPEC       = 0,
        PF_APPLETALK    = AF_APPLETALK,
        PF_IPX          = AF_IPX
    }

    enum
    {
        SHUT_RD,
        SHUT_WR,
        SHUT_RDWR
    }

    int     accept(int, sockaddr*, socklen_t*);
    int     bind(int, in sockaddr*, socklen_t);
    int     connect(int, in sockaddr*, socklen_t);
    int     getpeername(int, sockaddr*, socklen_t*);
    int     getsockname(int, sockaddr*, socklen_t*);
    int     getsockopt(int, int, int, void*, socklen_t*);
    int     listen(int, int);
    ssize_t recv(int, void*, size_t, int);
    ssize_t recvfrom(int, void*, size_t, int, sockaddr*, socklen_t*);
    ssize_t recvmsg(int, msghdr*, int);
    ssize_t send(int, in void*, size_t, int);
    ssize_t sendmsg(int, in msghdr*, int);
    ssize_t sendto(int, in void*, size_t, int, in sockaddr*, socklen_t);
    int     setsockopt(int, int, int, in void*, socklen_t);
    int     shutdown(int, int);
    int     socket(int, int, int);
    int     sockatmark(int);
    int     socketpair(int, int, int, ref int[2]);
}
else
{
    static assert(false, "Unsupported platform");
}

//
// IPV6 (IP6)
//
/*
AF_INET6
*/

version( Linux )
{
    enum
    {
        AF_INET6    = 10
    }
}
else version( OSX )
{
    enum
    {
        AF_INET6    = 30
    }
}
else
{
    static assert(false, "Unsupported platform");
}

//
// Raw Sockets (RS)
//
/*
SOCK_RAW
*/

version( Linux )
{
    enum
    {
        SOCK_RAW    = 3
    }
}
else version( OSX )
{
    enum
    {
        SOCK_RAW    = 3
    }
}
else
{
    static assert(false, "Unsupported platform");
}
