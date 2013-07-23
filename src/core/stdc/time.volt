// Copyright © 2005-2009, Sean Kelly.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.time;

private import core.stdc.config; // c_long


extern(C):
@trusted: // There are only a few functions here that use unsafe C strings.
nothrow:

version (Windows) {

	struct tm
	{
		int     tm_sec;     // seconds after the minute - [0, 60]
		int     tm_min;     // minutes after the hour - [0, 59]
		int     tm_hour;    // hours since midnight - [0, 23]
		int     tm_mday;    // day of the month - [1, 31]
		int     tm_mon;     // months since January - [0, 11]
		int     tm_year;    // years since 1900
		int     tm_wday;    // days since Sunday - [0, 6]
		int     tm_yday;    // days since January 1 - [0, 365]
		int     tm_isdst;   // Daylight Saving Time flag
	}

} else version (Posix) {

	struct tm
	{
		int     tm_sec;     // seconds after the minute [0-60]
		int     tm_min;     // minutes after the hour [0-59]
		int     tm_hour;    // hours since midnight [0-23]
		int     tm_mday;    // day of the month [1-31]
		int     tm_mon;     // months since January [0-11]
		int     tm_year;    // years since 1900
		int     tm_wday;    // days since Sunday [0-6]
		int     tm_yday;    // days since January 1 [0-365]
		int     tm_isdst;   // Daylight Savings Time flag
		c_long  tm_gmtoff;  // offset from CUT in seconds
		char*   tm_zone;    // timezone abbreviation
	}

} else {

	static assert(false, "unsupported platform");

}

alias time_t = c_long;
alias clock_t = c_long;

version (Windows) {

	enum clock_t CLOCKS_PER_SEC = 1000;

} else version (Linux) {

	enum clock_t CLOCKS_PER_SEC = 1000000;

} else version (OSX) {

	enum clock_t CLOCKS_PER_SEC = 100;

} else version (FreeBSD) {

	enum clock_t CLOCKS_PER_SEC = 128;

}


clock_t clock();
double  difftime(time_t time1, time_t time0);
time_t  mktime(tm* timeptr);
time_t  time(time_t* timer);
char*   asctime(in tm* timeptr);
char*   ctime(in time_t* timer);
tm*     gmtime(in time_t* timer);
tm*     localtime(in time_t* timer);
@system size_t  strftime(char* s, size_t maxsize, in char* format, in tm* timeptr);

version (Windows) {

	void  tzset();                   // non-standard
	void  _tzset();                  // non-standard
	@system char* _strdate(char* s); // non-standard
	@system char* _strtime(char* s); // non-standard

	//extern global const(char)*[2] tzname; // non-standard

} else version (Linux) {

	void tzset();                         // non-standard
	//extern global const(char)*[2] tzname; // non-standard

} else version (OSX) {

	void tzset();                         // non-standard
	//extern global const(char)*[2] tzname; // non-standard

} else /+version (FreeBSD) {

	void tzset();                         // non-standard
	//extern global const(char)*[2] tzname; // non-standard

} else+/ {

	static assert(false, "not a supported platform");

}
