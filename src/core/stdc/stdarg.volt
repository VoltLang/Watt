// Copyright © 2013, Jakob Bornecrantz.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
module core.stdc.stdarg;

import core.compiler.varargs;


extern(C):
@system: // Types only.
nothrow:

alias va_list = void*;
alias va_start = __llvm_volt_va_start;
alias va_end = __llvm_volt_va_end;
