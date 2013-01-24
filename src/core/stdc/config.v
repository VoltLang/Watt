// Copyright © 2005-2009, Sean Kelly.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.config;


extern(C):
@trusted: // Types only.
nothrow:

version( Windows ) {

	alias c_long  =  int;
	alias c_ulong = uint;

} else {

	version (V_P64) {

		alias c_long  =  long;
		alias c_ulong = ulong;

	} else {

		alias c_long  =  int;
		alias c_ulong = uint;

	}
}
