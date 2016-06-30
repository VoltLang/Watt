// Copyright © 2013, Jakob Bornecrantz.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
module core.stdc.stdarg;

static import object;


extern(C):
@system: // Types only.
nothrow:

alias va_list = void*;
alias va_start = object.__llvm_volt_va_start;
alias va_end = object.__llvm_volt_va_end;
