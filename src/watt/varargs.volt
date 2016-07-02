// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.varargs;

import core.compiler.varargs;


alias va_list = void*;

alias va_start = __volt_va_start;
alias va_end = __volt_va_end;

