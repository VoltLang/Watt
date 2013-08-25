// Copyright © 2005-2009, Sean Kelly.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.wchar_;

private import core.stdc.config;
private import core.stdc.stdarg : va_list;
private import core.stdc.stdio : FILE;
public import core.stdc.stddef : wchar_t;
public import core.stdc.time : tm, time_t;
public import core.stdc.stdint;  // for WCHAR_MIN, WCHAR_MAX


extern (C):
@system:
nothrow:

alias mbstate_t = int;
alias wint_t = wchar_t;

enum wchar_t WEOF = 0xFFFF;

int fwprintf(FILE* stream, in wchar_t* format, ...);
int fwscanf(FILE* stream, in wchar_t* format, ...);
int swprintf(wchar_t* s, size_t n, in wchar_t* format, ...);
int swscanf(in wchar_t* s, in wchar_t* format, ...);
int vfwprintf(FILE* stream, in wchar_t* format, va_list arg);
int vfwscanf(FILE* stream, in wchar_t* format, va_list arg);
int vswprintf(wchar_t* s, size_t n, in wchar_t* format, va_list arg);
int vswscanf(in wchar_t* s, in wchar_t* format, va_list arg);
int vwprintf(in wchar_t* format, va_list arg);
int vwscanf(in wchar_t* format, va_list arg);
int wprintf(in wchar_t* format, ...);
int wscanf(in wchar_t* format, ...);

// No unsafe pointer manipulation.
@trusted
{
	wint_t fgetwc(FILE* stream);
	wint_t fputwc(wchar_t c, FILE* stream);
}

wchar_t* fgetws(wchar_t* s, int n, FILE* stream);
int      fputws(in wchar_t* s, FILE* stream);

// No unsafe pointer manipulation.
extern(Volt) @trusted
{
//	wint_t getwchar()                     { return fgetwc(stdin);     }
//	wint_t putwchar(wchar_t c)            { return fputwc(c,stdout);  }
//	wint_t getwc(FILE* stream)            { return fgetwc(stream);    }
//	wint_t putwc(wchar_t c, FILE* stream) { return fputwc(c, stream); }
}

// No unsafe pointer manipulation.
@trusted
{
	wint_t ungetwc(wint_t c, FILE* stream);
	int    fwide(FILE* stream, int mode);
}

double  wcstod(in wchar_t* nptr, wchar_t** endptr);
float   wcstof(in wchar_t* nptr, wchar_t** endptr);
//real    wcstold(in wchar_t* nptr, wchar_t** endptr);
c_long  wcstol(in wchar_t* nptr, wchar_t** endptr, int base);
long    wcstoll(in wchar_t* nptr, wchar_t** endptr, int base);
c_ulong wcstoul(in wchar_t* nptr, wchar_t** endptr, int base);
ulong   wcstoull(in wchar_t* nptr, wchar_t** endptr, int base);

wchar_t* wcscpy(wchar_t* s1, in wchar_t* s2);
wchar_t* wcsncpy(wchar_t* s1, in wchar_t* s2, size_t n);
wchar_t* wcscat(wchar_t* s1, in wchar_t* s2);
wchar_t* wcsncat(wchar_t* s1, in wchar_t* s2, size_t n);
int      wcscmp(in wchar_t* s1, in wchar_t* s2);
int      wcscoll(in wchar_t* s1, in wchar_t* s2);
int      wcsncmp(in wchar_t* s1, in wchar_t* s2, size_t n);
size_t   wcsxfrm(wchar_t* s1, in wchar_t* s2, size_t n);
wchar_t* wcschr(in wchar_t* s, wchar_t c);
size_t   wcscspn(in wchar_t* s1, in wchar_t* s2);
wchar_t* wcspbrk(in wchar_t* s1, in wchar_t* s2);
wchar_t* wcsrchr(in wchar_t* s, wchar_t c);
size_t   wcsspn(in wchar_t* s1, in wchar_t* s2);
wchar_t* wcsstr(in wchar_t* s1, in wchar_t* s2);
wchar_t* wcstok(wchar_t* s1, in wchar_t* s2, wchar_t** ptr);
size_t   wcslen(in wchar_t* s);

wchar_t* wmemchr(in wchar_t* s, wchar_t c, size_t n);
int      wmemcmp(in wchar_t* s1, in wchar_t* s2, size_t n);
wchar_t* wmemcpy(wchar_t* s1, in wchar_t* s2, size_t n);
wchar_t* wmemmove(wchar_t*s1, in wchar_t* s2, size_t n);
wchar_t* wmemset(wchar_t* s, wchar_t c, size_t n);

size_t wcsftime(wchar_t* s, size_t maxsize, in wchar_t* format, in tm* timeptr);

version (Windows) {

    wchar_t* _wasctime(tm*);      // non-standard
    wchar_t* _wctime(time_t*);    // non-standard
    wchar_t* _wstrdate(wchar_t*); // non-standard
    wchar_t* _wstrtime(wchar_t*); // non-standard

}

// No unsafe pointer manipulation.
@trusted
{
	wint_t btowc(int c);
	int    wctob(wint_t c);
}

int    mbsinit(in mbstate_t* ps);
size_t mbrlen(in char* s, size_t n, mbstate_t* ps);
size_t mbrtowc(wchar_t* pwc, in char* s, size_t n, mbstate_t* ps);
size_t wcrtomb(char* s, wchar_t wc, mbstate_t* ps);
size_t mbsrtowcs(wchar_t* dst, in char** src, size_t len, mbstate_t* ps);
size_t wcsrtombs(char* dst, in wchar_t** src, size_t len, mbstate_t* ps);
