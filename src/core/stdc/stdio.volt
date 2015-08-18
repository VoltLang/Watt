// Copyright © 2005-2009, Sean Kelly.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.stdc.stdio;

private
{
	import core.stdc.config;
	import core.stdc.stddef; // for size_t
	import core.stdc.stdarg; // for va_list

	/+version (FreeBSD) {
		import core.sys.posix.sys.types;
	}+/
}


extern(C):
@system:
nothrow:

version (Windows) {

	enum
	{
		BUFSIZ       = 0x4000,
		EOF          = -1,
		FOPEN_MAX    = 20,
		FILENAME_MAX = 256, // 255 plus NULL
		TMP_MAX      = 32767,
		SYS_OPEN     = 20,      // non-standard
	}

	enum int     _NFILE     = 60;       // non-standard
	enum string  _P_tmpdir  = "\\"; // non-standard
//	enum string _wP_tmpdir = "\\"; // non-standard
//	enum int     L_tmpnam   = _P_tmpdir.length + 12;

} else version (Linux) {

	enum {
		BUFSIZ       = 8192,
		EOF          = -1,
		FOPEN_MAX    = 16,
		FILENAME_MAX = 4095,
		TMP_MAX      = 238328,
		L_tmpnam     = 20,
	}

} else version (OSX) {

	enum
	{
		BUFSIZ       = 1024,
		EOF          = -1,
		FOPEN_MAX    = 20,
		FILENAME_MAX = 1024,
		TMP_MAX      = 308915776,
		L_tmpnam     = 1024,
	}

	private
	{
		struct __sbuf
		{
			ubyte*  _base;
			int     _size;
		}

		struct __sFILEX
		{

		}
	}

} else /+version (FreeBSD) {

	enum
	{
		BUFSIZ       = 1024,
		EOF          = -1,
		FOPEN_MAX    = 20,
		FILENAME_MAX = 1024,
		TMP_MAX      = 308915776,
		L_tmpnam     = 1024
	}

	struct __sbuf
	{
		ubyte *_base;
		int _size;
	}

	alias _iobuf __sFILE;

	union __mbstate_t // <sys/_types.h>
	{
		char[128]   _mbstate8;
		long        _mbstateL;
	}

} else+/ version (Emscripten) {

	enum {
		BUFSIZ       = 1024,
		EOF          = -1,
		FOPEN_MAX    = 20,
		FILENAME_MAX = 1024,
		TMP_MAX      = 26,
		L_tmpnam     = 1024,
	}

} else {

	static assert( false, "Unsupported platform" );

}

enum
{
	SEEK_SET,
	SEEK_CUR,
	SEEK_END
}

version (Windows) {

	struct _iobuf
	{
		char* _ptr;
		int   _cnt;
		char* _base;
		int   _flag;
		int   _file;
		int   _charbuf;
		int   _bufsiz;
		char* __tmpnum;
	}

} else version (Linux) {

	align(1) struct _iobuf
	{
		int     _flags;
		char*   _read_ptr;
		char*   _read_end;
		char*   _read_base;
		char*   _write_base;
		char*   _write_ptr;
		char*   _write_end;
		char*   _buf_base;
		char*   _buf_end;
		char*   _save_base;
		char*   _backup_base;
		char*   _save_end;
		void*   _markers;
		_iobuf* _chain;
		int     _fileno;
		int     _blksize;
		int     _old_offset;
		ushort  _cur_column;
		byte    _vtable_offset;
		char[1] _shortbuf;
		void*   _lock;
	}

} else version (OSX) {

	align (1) struct _iobuf
	{
		ubyte*    _p;
		int       _r;
		int       _w;
		short     _flags;
		short     _file;
		__sbuf    _bf;
		int       _lbfsize;

		int* function(void*)                    _close;
		int* function(void*, char*, int)        _read;
		fpos_t* function(void*, fpos_t, int)    _seek;
		int* function(void*, char *, int)       _write;

		__sbuf    _ub;
		__sFILEX* _extra;
		int       _ur;

		ubyte[3]  _ubuf;
		ubyte[1]  _nbuf;

		__sbuf    _lb;

		int       _blksize;
		fpos_t    _offset;
	}

} else /+version (FreeBSD) {

	align (1) struct _iobuf
	{
		ubyte*          _p;
		int             _r;
		int             _w;
		short           _flags;
		short           _file;
		__sbuf          _bf;
		int             _lbfsize;

		void*           _cookie;
		int     function(void*)                 _close;
		int     function(void*, char*, int)     _read;
		fpos_t  function(void*, fpos_t, int)    _seek;
		int     function(void*, in char*, int)  _write;

		__sbuf          _ub;
		ubyte*          _up;
		int             _ur;

		ubyte[3]        _ubuf;
		ubyte[1]        _nbuf;

		__sbuf          _lb;

		int             _blksize;
		fpos_t          _offset;

		pthread_mutex_t _fl_mutex;
		pthread_t       _fl_owner;
		int             _fl_count;
		int             _orientation;
		__mbstate_t     _mbstate;
	}

} else+/ version (Emscripten) {

	// XXX not correct.
	struct _iobuf {}

} else {

	static assert( false, "Unsupported platform" );

}


alias FILE = _iobuf;

enum
{
	_F_RDWR = 0x0003, // non-standard
	_F_READ = 0x0001, // non-standard
	_F_WRIT = 0x0002, // non-standard
	_F_BUF  = 0x0004, // non-standard
	_F_LBUF = 0x0008, // non-standard
	_F_ERR  = 0x0010, // non-standard
	_F_EOF  = 0x0020, // non-standard
	_F_BIN  = 0x0040, // non-standard
	_F_IN   = 0x0080, // non-standard
	_F_OUT  = 0x0100, // non-standard
	_F_TERM = 0x0200, // non-standard
}

version (Windows) {

    enum
    {
        _IOFBF   = 0,
        _IOLBF   = 0x40,
        _IONBF   = 4,
        _IOREAD  = 1,     // non-standard
        _IOWRT   = 2,     // non-standard
        _IOMYBUF = 8,     // non-standard
        _IOEOF   = 0x10,  // non-standard
        _IOERR   = 0x20,  // non-standard
        _IOSTRG  = 0x40,  // non-standard
        _IORW    = 0x80,  // non-standard
        _IOTRAN  = 0x100, // non-standard
        _IOAPP   = 0x200, // non-standard
    }

    extern global void function() _fcloseallp;

    private extern global FILE[/+_NFILE+/60] _iob;

    @property FILE* stdin()  { return cast(FILE*) &_iob[0]; }
    @property FILE* stdout() { return cast(FILE*) &_iob[1]; }
    @property FILE* stderr() { return cast(FILE*) &_iob[2]; }
    @property FILE* stdaux() { return cast(FILE*) &_iob[3]; }
    @property FILE* stdprn() { return cast(FILE*) &_iob[4]; }

} else version (Linux) {

	enum
	{
		_IOFBF = 0,
		_IOLBF = 1,
		_IONBF = 2,
	}

	extern global FILE* stdin;
	extern global FILE* stdout;
	extern global FILE* stderr;

} else version (OSX) {

	enum
	{
		_IOFBF = 0,
		_IOLBF = 1,
		_IONBF = 2,
	}

	private extern global /*shared*/ FILE* __stdinp;
	private extern global /*shared*/ FILE* __stdoutp;
	private extern global /*shared*/ FILE* __stderrp;

	alias stdin = __stdinp;
	alias stdout = __stdoutp;
	alias stderr = __stderrp;

} else /+version (FreeBSD) {

	enum
	{
		_IOFBF = 0,
		_IOLBF = 1,
		_IONBF = 2,
	}

	private extern shared FILE* __stdinp;
	private extern shared FILE* __stdoutp;
	private extern shared FILE* __stderrp;

	alias __stdinp  stdin;
	alias __stdoutp stdout;
	alias __stderrp stderr;

} else+/ version (Emscripten) {

	enum
	{
		_IOFBF = 0,
		_IOLBF = 1,
		_IONBF = 2,
	}

	extern global FILE* stdin;
	extern global FILE* stdout;
	extern global FILE* stderr;

} else {

	static assert( false, "Unsupported platform" );

}

alias fpos_t = int;

int remove(in char* filename);
int rename(in char* from, in char* to);

@trusted FILE* tmpfile(); // No unsafe pointer manipulation.
char* tmpnam(char* s);

int   fclose(FILE* stream);

// No unsafe pointer manipulation.
@trusted int fflush(FILE* stream);

FILE* fopen(in char* filename, in char* mode);
FILE* freopen(in char* filename, in char* mode, FILE* stream);

void setbuf(FILE* stream, char* buf);
int  setvbuf(FILE* stream, char* buf, int mode, size_t size);

int fprintf(FILE* stream, in const(char)* format, ...);
int fscanf(FILE* stream, in const(char)* format, ...);
int sprintf(const(char)* s, in const(char)* format, ...);
int sscanf(in const(char)* s, in const(char)* format, ...);
int vfprintf(FILE* stream, in const(char)* format, va_list arg);
int vfscanf(FILE* stream, in const(char)* format, va_list arg);
int vsprintf(const(char)* s, in const(char)* format, va_list arg);
int vsscanf(in const(char)* s, in const(char)* format, va_list arg);
int vprintf(in const(char)* format, va_list arg);
int vscanf(in const(char)* format, va_list arg);
int printf(in const(char)* format, ...);
int scanf(in const(char)* format, ...);

// No usafe pointer manipulation.
@trusted
{
	int fgetc(FILE* stream);
	int fputc(int c, FILE* stream);
}

char* fgets(char* s, int n, FILE* stream);
int   fputs(in char* s, FILE* stream);
char* gets(char* s);
int   puts(in char* s);

// No unsafe pointer manipulation.
extern(Volt) @trusted
{
	int getchar()                 { return getc(stdin);     }
	int putchar(int c)            { return putc(c, stdout);  }
	int getc(FILE* stream)        { return fgetc(stream);   }
	int putc(int c, FILE* stream) { return fputc(c, stream); }
}

@trusted int ungetc(int c, FILE* stream); // No unsafe pointer manipulation.

size_t fread(void* ptr, size_t size, size_t nmemb, FILE* stream);
size_t fwrite(in void* ptr, size_t size, size_t nmemb, FILE* stream);

// No unsafe pointer manipulation.
@trusted
{
	int fgetpos(FILE* stream, fpos_t * pos);
	int fsetpos(FILE* stream, in fpos_t* pos);

	int    fseek(FILE* stream, c_long offset, int whence);
	c_long ftell(FILE* stream);
}

version (Windows) {

	/+
	// No unsafe pointer manipulation.
	extern(D) @trusted
	{
		void rewind(FILE* stream)   { fseek(stream,0L,SEEK_SET); stream._flag&=~_IOERR; }
		pure void clearerr(FILE* stream) { stream._flag &= ~(_IOERR|_IOEOF);                 }
		pure int  ferror(FILE* stream)   { return stream._flag&_IOERR;                       }
	}+/

	int feof(FILE* stream);

	int   _snprintf(char* s, size_t n, char* fmt, ...);
	alias snprintf = _snprintf;

	int   _vsnprintf(char* s, size_t n, in char* format, va_list arg);
	alias vsnprintf = _vsnprintf;

} else version (Linux) {

	// No unsafe pointer manipulation.
	@trusted
	{
		void rewind(FILE* stream);
		pure void clearerr(FILE* stream);
		pure int  feof(FILE* stream);
		pure int  ferror(FILE* stream);
		int  fileno(FILE *);
	}

	int  snprintf(char* s, size_t n, in char* format, ...);
	int  vsnprintf(char* s, size_t n, in char* format, va_list arg);

} else version (OSX) {

	// No unsafe pointer manipulation.
	@trusted
	{
		void rewind(FILE*);
		pure void clearerr(FILE*);
		pure int  feof(FILE*);
		pure int  ferror(FILE*);
		int  fileno(FILE*);
	}

	int  snprintf(char* s, size_t n, in char* format, ...);
	int  vsnprintf(char* s, size_t n, in char* format, va_list arg);

} else /+version (FreeBSD) {

	// No unsafe pointer manipulation.
	@trusted
	{
		void rewind(FILE*);
		pure void clearerr(FILE*);
		pure int  feof(FILE*);
		pure int  ferror(FILE*);
		int  fileno(FILE*);
	}

	int  snprintf(char* s, size_t n, in char* format, ...);
	int  vsnprintf(char* s, size_t n, in char* format, va_list arg);

} else+/ version (Emscripten) {

	// No unsafe pointer manipulation.
	@trusted
	{
		void rewind(FILE* stream);
		pure void clearerr(FILE* stream);
		pure int  feof(FILE* stream);
		pure int  ferror(FILE* stream);
		int  fileno(FILE *);
	}

	int  snprintf(char* s, size_t n, in char* format, ...);
	int  vsnprintf(char* s, size_t n, in char* format, va_list arg);

} else {

    static assert( false, "Unsupported platform" );

}

void perror(in char* s);
int unlink(const char* s);
