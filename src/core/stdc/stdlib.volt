// Copyright © 2005-2009, Sean Kelly.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.stdlib;

private import core.stdc.config;
public import core.stdc.stddef; // for size_t, wchar_t


extern(C):
@system:
nothrow:

struct div_t
{
	int quot;
	int rem;
}

struct ldiv_t
{
	int quot;
	int rem;
}

struct lldiv_t
{
	long quot;
	long rem;
}

enum EXIT_SUCCESS = 0;
enum EXIT_FAILURE = 1;
enum MB_CUR_MAX   = 1;

version (Windows)      enum RAND_MAX = 0x7fff;
else version (Linux)   enum RAND_MAX = 0x7fffffff;
else version (OSX)     enum RAND_MAX = 0x7fffffff;
else version (FreeBSD) enum RAND_MAX = 0x7fffffff;
else version (Solaris) enum RAND_MAX = 0x7fff;
else static assert(false, "Unsupported platform");

double  atof(in char* nptr);
int     atoi(in char* nptr);
c_long  atol(in char* nptr);
long    atoll(in char* nptr);

double  strtod(in char* nptr, char** endptr);
float   strtof(in char* nptr, char** endptr);
//real  strtold(in char* nptr, char** endptr);
c_long  strtol(in char* nptr, char** endptr, int base);
long    strtoll(in char* nptr, char** endptr, int base);
c_ulong strtoul(in char* nptr, char** endptr, int base);
ulong   strtoull(in char* nptr, char** endptr, int base);

// No unsafe pointer manipulation.
@trusted
{
	int     rand();
	void    srand(uint seed);
}

// We don't mark these @trusted. Given that they return a void*, one has
// to do a pointer cast to do anything sensible with the result. Thus,
// functions using these already have to be @trusted, allowing them to
// call @system stuff anyway.
void*   malloc(size_t size);
void*   calloc(size_t nmemb, size_t size);
void*   realloc(void* ptr, size_t size);
void    free(void* ptr);

void    abort();
void    exit(int status);
int     atexit(void function() func);
void    _Exit(int status);

char*   getenv(in char* name);
int     system(in char* string);

void*   bsearch(in void* key, in void* base, size_t nmemb, size_t size, int function(in void*, in void*) compar);
void    qsort(void* base, size_t nmemb, size_t size, int function(in void*, in void*) compar);

// These only operate on integer values.
@trusted
{
	pure int     abs(int j);
	pure c_long  labs(c_long j);
	pure long    llabs(long j);

	div_t   div(int numer, int denom);
	ldiv_t  ldiv(c_long numer, c_long denom);
	lldiv_t lldiv(long numer, long denom);
}

int     mblen(in char* s, size_t n);
int     mbtowc(wchar_t* pwc, in char* s, size_t n);
int     wctomb(char*s, wchar_t wc);
size_t  mbstowcs(wchar_t* pwcs, in char* s, size_t n);
size_t  wcstombs(char* s, in wchar_t* pwcs, size_t n);
