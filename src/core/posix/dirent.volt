// Copyright © 2005-2009, Sean Kelly.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.posix.dirent;

private import core.posix.config;
public import core.posix.sys.types; // for ino_t


extern(C):
@system: // Not checked properly.
nothrow:

//
// Required
//
/*
DIR

struct dirent
{
    char[] d_name;
}

int     closedir(DIR*);
DIR*    opendir(in char*);
dirent* readdir(DIR*);
void    rewinddir(DIR*);
*/

version (Linux) {

	// NOTE: The following constants are non-standard Linux definitions
	//       for dirent.d_type.
	enum
	{
		DT_UNKNOWN  = 0,
		DT_FIFO     = 1,
		DT_CHR      = 2,
		DT_DIR      = 4,
		DT_BLK      = 6,
		DT_REG      = 8,
		DT_LNK      = 10,
		DT_SOCK     = 12,
		DT_WHT      = 14
	}

	struct dirent
	{
		ino_t       d_ino;
		off_t       d_off;
		ushort      d_reclen;
		ubyte       d_type;
		char[256]   d_name;
	}

	struct DIR
	{
		// Managed by OS
	}

	// static if (__USE_LARGEFILE64)
	version (none) {

		dirent* readdir64(DIR*);
		alias readdir = readdir64;

	} else {

		dirent* readdir(DIR*);

	}

	DIR* opendir(const(char)*);
	int     closedir(DIR*);

} else version (OSX) {

	enum
	{
		DT_UNKNOWN  = 0,
		DT_FIFO     = 1,
		DT_CHR      = 2,
		DT_DIR      = 4,
		DT_BLK      = 6,
		DT_REG      = 8,
		DT_LNK      = 10,
		DT_SOCK     = 12,
		DT_WHT      = 14
	}

	align(4) struct dirent
	{
		ino_t       d_ino;
		ushort      d_reclen;
		ubyte       d_type;
		ubyte       d_namlen;
		char[256]   d_name;
	}

	struct DIR
	{
		// Managed by OS
	}

	dirent* readdir(DIR*);
	DIR* opendir(const(char)*);
	int     closedir(DIR*);

} else /+version (FreeBSD) {

	enum
	{
		DT_UNKNOWN  = 0,
		DT_FIFO     = 1,
		DT_CHR      = 2,
		DT_DIR      = 4,
		DT_BLK      = 6,
		DT_REG      = 8,
		DT_LNK      = 10,
		DT_SOCK     = 12,
		DT_WHT      = 14
	}

	align(4) struct dirent
	{
		uint      d_fileno;
		ushort    d_reclen;
		ubyte     d_type;
		ubyte     d_namlen;
		char[256] d_name;
	}

	alias DIR = void*;

	dirent* readdir(DIR*);

}+/


version (Posix)
{
    int     closedir(DIR*);
    DIR*    opendir(/*in*/ char*);
    //dirent* readdir(DIR*);
    void    rewinddir(DIR*);
}

//
// Thread-Safe Functions (TSF)
//
/*
int readdir_r(DIR*, dirent*, dirent**);
*/

version (Linux) {

	// static if (__USE_LARGEFILE64)
	version (none) {

		int   readdir64_r(DIR*, dirent*, dirent**);
		alias readdir_r = readdir64_r;

	} else {

		int readdir_r(DIR*, dirent*, dirent**);

	}

} else version (OSX) {

	int readdir_r(DIR*, dirent*, dirent**);

} else /+version (FreeBSD) {

	int readdir_r(DIR*, dirent*, dirent**);

}+/


//
// XOpen (XSI)
//
/*
void   seekdir(DIR*, c_long);
c_long telldir(DIR*);
*/

version (Linux) {

	void   seekdir(DIR*, c_long);
	c_long telldir(DIR*);

} else version (FreeBSD) {

	void   seekdir(DIR*, c_long);
	c_long telldir(DIR*);

}
