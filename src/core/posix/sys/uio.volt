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
module core.posix.sys.uio;

public import core.posix.sys.types; // for ssize_t

version (Posix):
extern (C):

//
// Required
//
/*
struct iovec
{
    void*  iov_base;
    size_t iov_len;
}

ssize_t // from core.sys.posix.sys.types
size_t  // from core.sys.posix.sys.types

ssize_t readv(int, in iovec*, int);
ssize_t writev(int, in iovec*, int);
*/

version( Linux )
{
    struct iovec
    {
        void*  iov_base;
        size_t iov_len;
    }

    ssize_t readv(int, in iovec*, int);
    ssize_t writev(int, in iovec*, int);
}
else version( OSX )
{
    struct iovec
    {
        void*  iov_base;
        size_t iov_len;
    }

    ssize_t readv(int, in iovec*, int);
    ssize_t writev(int, in iovec*, int);
}
else
{
    static assert(false, "Unsupported platform");
}
