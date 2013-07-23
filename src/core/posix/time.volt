// Copyright © 2005-2009, Sean Kelly.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.posix.time;

private import core.posix.config;
public import core.stdc.time;
public import core.posix.sys.types;
//public import core.posix.signal; // for sigevent

version (Posix):
extern (C):

//
// Required (defined in core.stdc.time)
//
/*
char* asctime(in tm*);
clock_t clock();
char* ctime(in time_t*);
double difftime(time_t, time_t);
tm* gmtime(in time_t*);
tm* localtime(in time_t*);
time_t mktime(tm*);
size_t strftime(char*, size_t, in char*, in tm*);
time_t time(time_t*);
*/

version (Linux) {
	time_t timegm(tm*); // non-standard
} else version (OSX) {
	time_t timegm(tm*); // non-standard
} else version (FreeBSD) {
	time_t timegm(tm*); // non-standard
} else version (Solaris) {
	// Not supported.
} else {
	static assert(false, "Unsupported platform");
}

//
// C Extension (CX)
// (defined in core.stdc.time)
//
/*
char* tzname[];
void tzset();
*/

//
// Process CPU-Time Clocks (CPT)
//
/*
int clock_getcpuclockid(pid_t, clockid_t*);
*/

//
// Clock Selection (CS)
//
/*
int clock_nanosleep(clockid_t, int, in timespec*, timespec*);
*/

//
// Monotonic Clock (MON)
//
/*
CLOCK_MONOTONIC
*/

version (Linux) {
	enum CLOCK_MONOTONIC        = 1;
	enum CLOCK_MONOTONIC_RAW    = 4; // non-standard
	enum CLOCK_MONOTONIC_COARSE = 6; // non-standard
} else version (FreeBSD) {   // time.h
	enum CLOCK_MONOTONIC         = 4;
	enum CLOCK_MONOTONIC_PRECISE = 11;
	enum CLOCK_MONOTONIC_FAST    = 12;
} else version (OSX) {
	// No CLOCK_MONOTONIC defined
} else version (Solaris) {
	enum CLOCK_MONOTONIC = 4;
} else version (Windows) {
//	pragma(msg, "no Windows support for CLOCK_MONOTONIC");
} else {
	static assert(0);
}

//
// Timer (TMR)
//
/*
CLOCK_PROCESS_CPUTIME_ID (TMR|CPT)
CLOCK_THREAD_CPUTIME_ID (TMR|TCT)

NOTE: timespec must be defined in core.sys.posix.signal to break
	  a circular import.

struct timespec
{
	time_t  tv_sec;
	int     tv_nsec;
}

struct itimerspec
{
	timespec it_interval;
	timespec it_value;
}

CLOCK_REALTIME
TIMER_ABSTIME

clockid_t
timer_t

int clock_getres(clockid_t, timespec*);
int clock_gettime(clockid_t, timespec*);
int clock_settime(clockid_t, in timespec*);
int nanosleep(in timespec*, timespec*);
int timer_create(clockid_t, sigevent*, timer_t*);
int timer_delete(timer_t);
int timer_gettime(timer_t, itimerspec*);
int timer_getoverrun(timer_t);
int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
*/

version (Linux) {
	enum CLOCK_PROCESS_CPUTIME_ID = 2;
	enum CLOCK_THREAD_CPUTIME_ID  = 3;

	// NOTE: See above for why this is commented out.
	//
	//struct timespec
	//{
	//    time_t  tv_sec;
	//    c_long  tv_nsec;
	//}

	alias timespec = uint;

	struct itimerspec
	{
		timespec it_interval;
		timespec it_value;
	}

	enum CLOCK_REALTIME         = 0;
	enum CLOCK_REALTIME_COARSE  = 5; // non-standard
	enum TIMER_ABSTIME          = 0x01;

	alias clockid_t = int;
	alias timer_t = int;

	int clock_getres(clockid_t, timespec*);
	int clock_gettime(clockid_t, timespec*);
	int clock_settime(clockid_t, in timespec*);
	int nanosleep(in timespec*, timespec*);
	//int timer_create(clockid_t, sigevent*, timer_t*);
	int timer_delete(timer_t);
	int timer_gettime(timer_t, itimerspec*);
	int timer_getoverrun(timer_t);
	int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
} else version (OSX) {
	int nanosleep(in void*, void*);
} else version (FreeBSD) {
	//enum CLOCK_PROCESS_CPUTIME_ID = ??;
	enum CLOCK_THREAD_CPUTIME_ID  = 15;

	// NOTE: See above for why this is commented out.
	//
	//struct timespec
	//{
	//    time_t  tv_sec;
	//    c_long  tv_nsec;
	//}

	struct itimerspec
	{
		timespec it_interval;
		timespec it_value;
	}

	enum CLOCK_REALTIME     = 0;
	enum TIMER_ABSTIME      = 0x01;

	alias clockid_t = int; // <sys/_types.h>
	alias timer_t = int;

	int clock_getres(clockid_t, timespec*);
	int clock_gettime(clockid_t, timespec*);
	int clock_settime(clockid_t, in timespec*);
	int nanosleep(in timespec*, timespec*);
	int timer_create(clockid_t, sigevent*, timer_t*);
	int timer_delete(timer_t);
	int timer_gettime(timer_t, itimerspec*);
	int timer_getoverrun(timer_t);
	int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
} else version (Solaris) {
	struct itimerspec
	{
		timespec it_interval;
		timespec it_value;
	}

	enum TIMER_ABSOLUTE = 0x1;

	alias clockid_t = int;
	alias timer_t = int;

	int clock_getres(clockid_t, timespec*);
	int clock_gettime(clockid_t, timespec*);
	int clock_settime(clockid_t, in timespec*);
	int clock_nanosleep(clockid_t, int, in timespec*, timespec*);

	int nanosleep(in timespec*, timespec*);

	int timer_create(clockid_t, sigevent*, timer_t*);
	int timer_delete(timer_t);
	int timer_getoverrun(timer_t);
	int timer_gettime(timer_t, itimerspec*);
	int timer_settime(timer_t, int, in itimerspec*, itimerspec*);
} else {
	static assert(false, "Unsupported platform");
}

//
// Thread-Safe Functions (TSF)
//
/*
char* asctime_r(in tm*, char*);
char* ctime_r(in time_t*, char*);
tm*   gmtime_r(in time_t*, tm*);
tm*   localtime_r(in time_t*, tm*);
*/

version (Linux) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
} else version (OSX) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
} else version (FreeBSD) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm*   gmtime_r(in time_t*, tm*);
	tm*   localtime_r(in time_t*, tm*);
} else version (Solaris) {
	char* asctime_r(in tm*, char*);
	char* ctime_r(in time_t*, char*);
	tm* gmtime_r(in time_t*, tm*);
	tm* localtime_r(in time_t*, tm*);
} else {
	static assert(false, "Unsupported platform");
}

//
// XOpen (XSI)
//
/*
getdate_err

int daylight;
int timezone;

tm* getdate(in char*);
char* strptime(in char*, in char*, tm*);
*/

version (Linux) {
	extern global int    daylight;
	extern global c_long timezone;

	tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
} else version (OSX) {
	extern global c_long timezone;
	extern global int    daylight;

	tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
} else version (FreeBSD) {
	//tm*   getdate(in char*);
	char* strptime(in char*, in char*, tm*);
} else version (Solaris) {
	extern global c_long timezone, altzone;
	extern global int daylight;

	tm* getdate(in char*);
	char* __strptime_dontzero(in char*, in char*, tm*);
	alias strptime = __strptime_dontzero;
} else {
	static assert(false, "Unsupported platform");
}
