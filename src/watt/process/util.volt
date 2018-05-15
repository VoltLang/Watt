// Copyright 2016-2018, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
module watt.process.util;

version (Windows) {
	import win32 = core.c.windows;
} else {
	import unistd = core.c.posix.unistd;
}

/*!
 * Get the process id of the calling process.
 */
fn getpid() u32
{
	version (Windows) {
		return win32.GetCurrentProcessId();
	} else {
		return cast(u32)unistd.getpid();
	}
}
