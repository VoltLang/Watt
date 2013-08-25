// Copyright © 2005-2009, Sean Kelly.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.stddef;


extern(C):
@trusted: // Types only.
nothrow:

// size_t and ptrdiff_t are defined in the object module.

version (Windows) {

	alias wchar_t = ushort;

} else {

	alias wchar_t = uint;

}
