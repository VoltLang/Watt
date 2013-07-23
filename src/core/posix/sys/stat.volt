// Copyright © 2005-2009, Sean Kelly.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
// File taken from druntime, and modified for Volt.
module core.posix.sys.stat;

private import core.posix.config;
private import core.stdc.stdint;
private import core.posix.time;     // for timespec
public import core.stdc.stddef;          // for size_t
public import core.posix.sys.types; // for off_t, mode_t

version (Posix):
extern (C):

//
// Required
//
/*
struct stat
{
	dev_t   st_dev;
	ino_t   st_ino;
	mode_t  st_mode;
	nlink_t st_nlink;
	uid_t   st_uid;
	gid_t   st_gid;
	off_t   st_size;
	time_t  st_atime;
	time_t  st_mtime;
	time_t  st_ctime;
}

S_IRWXU
	S_IRUSR
	S_IWUSR
	S_IXUSR
S_IRWXG
	S_IRGRP
	S_IWGRP
	S_IXGRP
S_IRWXO
	S_IROTH
	S_IWOTH
	S_IXOTH
S_ISUID
S_ISGID
S_ISVTX

S_ISBLK(m)
S_ISCHR(m)
S_ISDIR(m)
S_ISFIFO(m)
S_ISREG(m)
S_ISLNK(m)
S_ISSOCK(m)

S_TYPEISMQ(buf)
S_TYPEISSEM(buf)
S_TYPEISSHM(buf)

int    chmod(in char*, mode_t);
int    fchmod(int, mode_t);
int    fstat(int, stat*);
int    lstat(in char*, stat*);
int    mkdir(in char*, mode_t);
int    mkfifo(in char*, mode_t);
int    stat(in char*, stat*);
mode_t umask(mode_t);
 */

alias ulong_t = ulong;
alias slong_t = long;

version (Linux) {
	version (X86) {
		struct stat_t
		{
			dev_t       st_dev;
			ushort      __pad1;
//			static if (!__USE_FILE_OFFSET64)
//			{
				ino_t       st_ino;
//			}
//			else
//			{
//				uint        __st_ino;
//			}
			mode_t      st_mode;
			nlink_t     st_nlink;
			uid_t       st_uid;
			gid_t       st_gid;
			dev_t       st_rdev;
			ushort      __pad2;
			off_t       st_size;
			blksize_t   st_blksize;
			blkcnt_t    st_blocks;
	//		static if (__USE_MISC || __USE_XOPEN2K8)
//			{
//				timespec    st_atim;
//				timespec    st_mtim;
//				timespec    st_ctim;
//				extern(D)
//				{
//					@property /*ref */time_t st_atime() { return st_atim.tv_sec; }
//					@property /*ref */time_t st_mtime() { return st_mtim.tv_sec; }
//					@property /*ref */time_t st_ctime() { return st_ctim.tv_sec; }
//				}
//			}
//			else
//			{
				time_t      st_atime;
				ulong_t     st_atimensec;
				time_t      st_mtime;
				ulong_t     st_mtimensec;
				time_t      st_ctime;
				ulong_t     st_ctimensec;
//			}
//			static if (__USE_FILE_OFFSET64)
//			{
//				ino_t       st_ino;
//			}
//			else
//			{
				ulong_t     __unused4;
				ulong_t     __unused5;
//			}
		}
	} else version (X86_64) {
		struct stat_t
		{
			dev_t       st_dev;
			ino_t       st_ino;
			nlink_t     st_nlink;
			mode_t      st_mode;
			uid_t       st_uid;
			gid_t       st_gid;
			uint        __pad0;
			dev_t       st_rdev;
			off_t       st_size;
			blksize_t   st_blksize;
			blkcnt_t    st_blocks;
			/+static if (__USE_MISC || __USE_XOPEN2K8)
			{
				timespec    st_atim;
				timespec    st_mtim;
				timespec    st_ctim;
				extern(D)
				{
					@property /*ref */ time_t st_atime() { return st_atim.tv_sec; }
					@property /*ref */ time_t st_mtime() { return st_mtim.tv_sec; }
					@property /*ref */ time_t st_ctime() { return st_ctim.tv_sec; }
				}
			}
			else+/
			//{
				time_t      st_atime;
				ulong_t     st_atimensec;
				time_t      st_mtime;
				ulong_t     st_mtimensec;
				time_t      st_ctime;
				ulong_t     st_ctimensec;
			//}
			slong_t[3]     __unused;
		}
	} else version (MIPS_O32) {
		struct stat_t
		{
			c_ulong     st_dev;
			c_long[3]   st_pad1;
			ino_t       st_ino;
			mode_t      st_mode;
			nlink_t     st_nlink;
			uid_t       st_uid;
			gid_t       st_gid;
			c_ulong     st_rdev;
			static if (!__USE_FILE_OFFSET64)
			{
				c_long[2]   st_pad2;
				off_t       st_size;
				c_long      st_pad3;
			}
			else
			{
				c_long[3]   st_pad2;
				off_t       st_size;
			}
			static if (__USE_MISC || __USE_XOPEN2K8)
			{
				timespec    st_atim;
				timespec    st_mtim;
				timespec    st_ctim;
				extern(D)
				{
					@property /*ref */ time_t st_atime() { return st_atim.tv_sec; }
					@property /*ref */ time_t st_mtime() { return st_mtim.tv_sec; }
					@property /*ref */ time_t st_ctime() { return st_ctim.tv_sec; }
				}
			}
			else
			{
				time_t      st_atime;
				c_ulong     st_atimensec;
				time_t      st_mtime;
				c_ulong     st_mtimensec;
				time_t      st_ctime;
				c_ulong     st_ctimensec;
			}
			blksize_t   st_blksize;
			static if (!__USE_FILE_OFFSET64)
			{
				blkcnt_t    st_blocks;
			}
			else
			{
				c_long      st_pad4;
				blkcnt_t    st_blocks;
			}
			c_long[14]  st_pad5;
		}
	} else version (PPC) {
		struct stat_t
		{
			c_ulong     st_dev;
			ino_t       st_ino;
			mode_t      st_mode;
			nlink_t     st_nlink;
			uid_t       st_uid;
			gid_t       st_gid;
			c_ulong     st_rdev;
			off_t       st_size;
			c_ulong     st_blksize;
			c_ulong     st_blocks;
			c_ulong     st_atime;
			c_ulong     st_atime_nsec;
			c_ulong     st_mtime;
			c_ulong     st_mtime_nsec;
			c_ulong     st_ctime;
			c_ulong     st_ctime_nsec;
			c_ulong     __unused4;
			c_ulong     __unused5;
		}
	} else version (PPC64) {
		struct stat_t
		{
			c_ulong     st_dev;
			ino_t       st_ino;
			nlink_t     st_nlink;
			mode_t      st_mode;
			uid_t       st_uid;
			gid_t       st_gid;
			c_ulong     st_rdev;
			off_t       st_size;
			c_ulong     st_blksize;
			c_ulong     st_blocks;
			c_ulong     st_atime;
			c_ulong     st_atime_nsec;
			c_ulong     st_mtime;
			c_ulong     st_mtime_nsec;
			c_ulong     st_ctime;
			c_ulong     st_ctime_nsec;
			c_ulong     __unused4;
			c_ulong     __unused5;
			c_ulong     __unused6;
		}
	} else version (ARM) {
		private
		{
			alias __dev_t = ulong;
			alias __ino_t = c_ulong;
			alias __ino64_t = ulong;
			alias __mode_t = uint;
			alias __nlink_t = size_t;
			alias __uid_t = uint;
			alias __gid_t = uint;
			alias __off_t = c_long;
			alias __off64_t = long;
			alias __blksize_t = c_long;
			alias __blkcnt_t = c_long;
			alias __blkcnt64_t = long;
			alias __timespec = timespec;
			alias __time_t = time_t;
		}
		struct stat_t
		{
			__dev_t st_dev;
			ushort __pad1;

			static if(!__USE_FILE_OFFSET64)
			{
				__ino_t st_ino;
			}
			else
			{
				__ino_t __st_ino;
			}
			__mode_t st_mode;
			__nlink_t st_nlink;
			__uid_t st_uid;
			__gid_t st_gid;
			__dev_t st_rdev;
			ushort __pad2;

			static if(!__USE_FILE_OFFSET64)
			{
				__off_t st_size;
			}
			else
			{
				__off64_t st_size;
			}
			__blksize_t st_blksize;
			
			static if(!__USE_FILE_OFFSET64)
			{
				__blkcnt_t st_blocks;
			}
			else
			{
				__blkcnt64_t st_blocks;
			}

			static if( __USE_MISC || __USE_XOPEN2K8)
			{
				__timespec st_atim;
				__timespec st_mtim;
				__timespec st_ctim;
				extern(D)
				{
					@property /*ref */ time_t st_atime() { return st_atim.tv_sec; }
					@property /*ref */ time_t st_mtime() { return st_mtim.tv_sec; }
					@property /*ref */ time_t st_ctime() { return st_ctim.tv_sec; }
				}
			}
			else
			{
				__time_t st_atime;
				c_ulong st_atimensec;
				__time_t st_mtime;
				c_ulong st_mtimensec;
				__time_t st_ctime;
				c_ulong st_ctimensec;
			}

			static if(!__USE_FILE_OFFSET64)
			{
				c_ulong __unused4;
				c_ulong __unused5;
			}
			else
			{
				__ino64_t st_ino;
			}
		}
		static if(__USE_FILE_OFFSET64)
			static assert(stat_t.sizeof == 104);
		else
			static assert(stat_t.sizeof == 88);
	} else {
		static assert(0, "unimplemented");
	}

	enum S_IRUSR    = 0x100; // octal 0400
	enum S_IWUSR    = 0x080; // octal 0200
	enum S_IXUSR    = 0x040; // octal 0100
	enum S_IRWXU    = S_IRUSR | S_IWUSR | S_IXUSR;

	//enum S_IRGRP    = S_IRUSR >> 3;
	enum S_IRGRP    = 0x020;
	//enum S_IWGRP    = S_IWUSR >> 3;
	//enum S_IXGRP    = S_IXUSR >> 3;
	//enum S_IRWXG    = S_IRWXU >> 3;
	enum S_IRWXG    = 0x038;

//	enum S_IROTH    = S_IRGRP >> 3;
//	enum S_IWOTH    = S_IWGRP >> 3;
//	enum S_IXOTH    = S_IXGRP >> 3;
//	enum S_IRWXO    = S_IRWXG >> 3;
	enum S_IRWXO    = 0x7;

	enum S_ISUID    = 0x800; // octal 04000
	enum S_ISGID    = 0x400; // octal 02000
	enum S_ISVTX    = 0x200; // octal 01000

	private
	{
		extern (D) bool S_ISTYPE( mode_t mode, uint mask )
		{
			return ( mode & S_IFMT ) == mask;
		}
	}

	extern (D) bool S_ISBLK( mode_t mode )  { return S_ISTYPE( mode, S_IFBLK );  }
	extern (D) bool S_ISCHR( mode_t mode )  { return S_ISTYPE( mode, S_IFCHR );  }
	extern (D) bool S_ISDIR( mode_t mode )  { return S_ISTYPE( mode, S_IFDIR );  }
	extern (D) bool S_ISFIFO( mode_t mode ) { return S_ISTYPE( mode, S_IFIFO );  }
	extern (D) bool S_ISREG( mode_t mode )  { return S_ISTYPE( mode, S_IFREG );  }
	extern (D) bool S_ISLNK( mode_t mode )  { return S_ISTYPE( mode, S_IFLNK );  }
	extern (D) bool S_ISSOCK( mode_t mode ) { return S_ISTYPE( mode, S_IFSOCK ); }

	//static if( true /*__USE_POSIX199309*/ )
	//{
		extern bool S_TYPEISMQ( stat_t* buf )  { return false; }
		extern bool S_TYPEISSEM( stat_t* buf ) { return false; }
		extern bool S_TYPEISSHM( stat_t* buf ) { return false; }
	//}
} else version (OSX) {
	struct stat_t
	{
		dev_t       st_dev;
		ino_t       st_ino;
		mode_t      st_mode;
		nlink_t     st_nlink;
		uid_t       st_uid;
		gid_t       st_gid;
		dev_t       st_rdev;
	  //static if( false /*!_POSIX_C_SOURCE || _DARWIN_C_SOURCE*/ )
	  //{
		  //timespec  st_atimespec;
		  //timespec  st_mtimespec;
		  //timespec  st_ctimespec;
	  //}
	  //else
	  //{
		time_t      st_atime;
		c_long      st_atimensec;
		time_t      st_mtime;
		c_long      st_mtimensec;
		time_t      st_ctime;
		c_long      st_ctimensec;
	  //}
		off_t       st_size;
		blkcnt_t    st_blocks;
		blksize_t   st_blksize;
		uint        st_flags;
		uint        st_gen;
		int         st_lspare;
		long[2]     st_qspare;
	}

	enum S_IRUSR    = 0x100; // octal 0400
	enum S_IWUSR    = 0x080; // octal 0200
	enum S_IXUSR    = 0x040; // octal 0100
	enum S_IRWXU    = S_IRUSR | S_IWUSR | S_IXUSR;

	//enum S_IRGRP    = S_IRUSR >> 3;
	enum S_IRGRP    = 0x020;
	//enum S_IWGRP    = S_IWUSR >> 3;
	//enum S_IXGRP    = S_IXUSR >> 3;
	//enum S_IRWXG    = S_IRWXU >> 3;
	enum S_IRWXG    = 0x038;

//	enum S_IROTH    = S_IRGRP >> 3;
//	enum S_IWOTH    = S_IWGRP >> 3;
//	enum S_IXOTH    = S_IXGRP >> 3;
//	enum S_IRWXO    = S_IRWXG >> 3;
	enum S_IRWXO    = 0x7;

	enum S_ISUID    = 0x800; // octal 04000
	enum S_ISGID    = 0x400; // octal 02000
	enum S_ISVTX    = 0x200; // octal 01000

	private
	{
//		extern (D) bool S_ISTYPE( mode_t mode, uint mask )
	//	{
		//	return ( mode & S_IFMT ) == mask;
		//}
	}

//	extern (D) bool S_ISBLK( mode_t mode )  { return S_ISTYPE( mode, S_IFBLK );  }
	//extern (D) bool S_ISCHR( mode_t mode )  { return S_ISTYPE( mode, S_IFCHR );  }
//	extern (D) bool S_ISDIR( mode_t mode )  { return S_ISTYPE( mode, S_IFDIR );  }
	//extern (D) bool S_ISFIFO( mode_t mode ) { return S_ISTYPE( mode, S_IFIFO );  }
	//extern (D) bool S_ISREG( mode_t mode )  { return S_ISTYPE( mode, S_IFREG );  }
	//extern (D) bool S_ISLNK( mode_t mode )  { return S_ISTYPE( mode, S_IFLNK );  }
	//extern (D) bool S_ISSOCK( mode_t mode ) { return S_ISTYPE( mode, S_IFSOCK ); }
} else version (FreeBSD) {
	struct stat_t
	{
		dev_t       st_dev;
		ino_t       st_ino;
		mode_t      st_mode;
		nlink_t     st_nlink;
		uid_t       st_uid;
		gid_t       st_gid;
		dev_t       st_rdev;

		time_t      st_atime;
		c_long      __st_atimensec;
		time_t      st_mtime;
		c_long      __st_mtimensec;
		time_t      st_ctime;
		c_long      __st_ctimensec;

		off_t       st_size;
		blkcnt_t    st_blocks;
		blksize_t   st_blksize;
		fflags_t    st_flags;
		uint        st_gen;
		int         st_lspare;

		time_t      st_birthtime;
		c_long      st_birthtimensec;

		//ubyte[16 - timespec.sizeof] padding;
	}

	enum S_IRUSR    = 0x100; // octal 0000400
	enum S_IWUSR    = 0x080; // octal 0000200
	enum S_IXUSR    = 0x040; // octal 0000100
	enum S_IRWXU    = 0x1C0; // octal 0000700

	enum S_IRGRP    = 0x020;  // octal 0000040
	enum S_IWGRP    = 0x010;  // octal 0000020
	enum S_IXGRP    = 0x008;  // octal 0000010
	enum S_IRWXG    = 0x038;  // octal 0000070

	enum S_IROTH    = 0x4; // 0000004
	enum S_IWOTH    = 0x2; // 0000002
	enum S_IXOTH    = 0x1; // 0000001
	enum S_IRWXO    = 0x7; // 0000007

	enum S_ISUID    = 0x800; // octal 0004000
	enum S_ISGID    = 0x400; // octal 0002000
	enum S_ISVTX    = 0x200; // octal 0001000

	private
	{
		extern (D) bool S_ISTYPE( mode_t mode, uint mask )
		{
			return ( mode & S_IFMT ) == mask;
		}
	}

	extern (D) bool S_ISBLK( mode_t mode )  { return S_ISTYPE( mode, S_IFBLK );  }
	extern (D) bool S_ISCHR( mode_t mode )  { return S_ISTYPE( mode, S_IFCHR );  }
	extern (D) bool S_ISDIR( mode_t mode )  { return S_ISTYPE( mode, S_IFDIR );  }
	extern (D) bool S_ISFIFO( mode_t mode ) { return S_ISTYPE( mode, S_IFIFO );  }
	extern (D) bool S_ISREG( mode_t mode )  { return S_ISTYPE( mode, S_IFREG );  }
	extern (D) bool S_ISLNK( mode_t mode )  { return S_ISTYPE( mode, S_IFLNK );  }
	extern (D) bool S_ISSOCK( mode_t mode ) { return S_ISTYPE( mode, S_IFSOCK ); }
} else version (Solaris) {
	private enum _ST_FSTYPSZ = 16;

	version (D_LP64) {
		struct stat64_t
		{
			dev_t st_dev;
			ino_t st_ino;
			mode_t st_mode;
			nlink_t st_nlink;
			uid_t st_uid;
			gid_t st_gid;
			dev_t st_rdev;
			off_t st_size;
			timestruc_t st_atim;
			timestruc_t st_mtim;
			timestruc_t st_ctim;
			blksize_t st_blksize;
			blkcnt_t st_blocks;
			char[_ST_FSTYPSZ] st_fstype;
		}

		alias stat32_t = stat64_t;
	} else {
		struct stat32_t
		{
			dev_t st_dev;
			c_long[3] st_pad1;
			ino_t st_ino;
			mode_t st_mode;
			nlink_t st_nlink;
			uid_t st_uid;
			gid_t st_gid;
			dev_t st_rdev;
			c_long[2] st_pad2;
			off_t st_size;
			c_long st_pad3;
			timestruc_t st_atim;
			timestruc_t st_mtim;
			timestruc_t st_ctim;
			blksize_t st_blksize;
			blkcnt_t st_blocks;
			char[_ST_FSTYPSZ] st_fstype;
			c_long[8] st_pad4;
		}

		struct stat64_t
		{
			dev_t st_dev;
			c_long[3] st_pad1;
			ino64_t st_ino;
			mode_t st_mode;
			nlink_t st_nlink;
			uid_t st_uid;
			gid_t st_gid;
			dev_t st_rdev;
			c_long[2] st_pad2;
			off64_t st_size;
			c_long st_pad3;
			timestruc_t st_atim;
			timestruc_t st_mtim;
			timestruc_t st_ctim;
			blksize_t st_blksize;
			blkcnt64_t st_blocks;
			char[_ST_FSTYPSZ] st_fstype;
			c_long[8] st_pad4;
		}
	}

	static if (__USE_FILE_OFFSET64)
		alias stat_t = stat64_t;
	else
		alias stat_t = stat32_t;

	enum S_IRUSR = 0x100;
	enum S_IWUSR = 0x080;
	enum S_IXUSR = 0x040;
	enum S_IRWXU = 0x1C0;

	enum S_IRGRP = 0x020;
	enum S_IWGRP = 0x010;
	enum S_IXGRP = 0x008;
	enum S_IRWXG = 0x038;

	enum S_IROTH = 0x4; // 0000004
	enum S_IWOTH = 0x2; // 0000002
	enum S_IXOTH = 0x1; // 0000001
	enum S_IRWXO = 0x7; // 0000007

	enum S_ISUID = 0x800;
	enum S_ISGID = 0x400;
	enum S_ISVTX = 0x200;

	private
	{
		extern (D) bool S_ISTYPE(mode_t mode, uint mask)
		{
			return (mode & S_IFMT) == mask;
		}
	}

	extern (D) bool S_ISBLK(mode_t mode) { return S_ISTYPE(mode, S_IFBLK); }
	extern (D) bool S_ISCHR(mode_t mode) { return S_ISTYPE(mode, S_IFCHR); }
	extern (D) bool S_ISDIR(mode_t mode) { return S_ISTYPE(mode, S_IFDIR); }
	extern (D) bool S_ISFIFO(mode_t mode) { return S_ISTYPE(mode, S_IFIFO); }
	extern (D) bool S_ISREG(mode_t mode) { return S_ISTYPE(mode, S_IFREG); }
	extern (D) bool S_ISLNK(mode_t mode) { return S_ISTYPE(mode, S_IFLNK); }
	extern (D) bool S_ISSOCK(mode_t mode) { return S_ISTYPE(mode, S_IFSOCK); }
} else {
	static assert(false, "Unsupported platform");
}

version (Posix) {
	int    chmod(in char*, mode_t);
	int    fchmod(int, mode_t);
	//int    fstat(int, stat_t*);
	//int    lstat(in char*, stat_t*);
	int    mkdir(in char*, mode_t);
	int    mkfifo(in char*, mode_t);
	//int    stat(in char*, stat_t*);
	mode_t umask(mode_t);
}

version (Linux) {
  /+static if( __USE_LARGEFILE64 )
  {
	int   fstat64(int, stat_t*);
	alias fstat = fstat64;

	int   lstat64(in char*, stat_t*);
	alias lstat = lstat64;

	int   stat64(in char*, stat_t*);
	alias stat = stat64;
  }+/
  //else
  //{
	int   fstat(int, stat_t*);
	int   lstat(in char*, stat_t*);
	int   stat(in char*, stat_t*);
  //}
} else version (Solaris) {
	static if (__USE_LARGEFILE64)
	{
		int   fstat64(int, stat_t*);
		alias fstat = fstat64;

		int   lstat64(in char*, stat_t*);
		alias lstat = lstat64;

		int   stat64(in char*, stat_t*);
		alias stat = stat64;
	}
	else
	{
		int fstat(int, stat_t*);
		int lstat(in char*, stat_t*);
		int stat(in char*, stat_t*);
	}
} else version(Posix) {
	int   fstat(int, stat_t*);
	int   lstat(in char*, stat_t*);
	int   stat(in char*, stat_t*);
}

//
// Typed Memory Objects (TYM)
//
/*
S_TYPEISTMO(buf)
*/

//
// XOpen (XSI)
//
/*
S_IFMT
S_IFBLK
S_IFCHR
S_IFIFO
S_IFREG
S_IFDIR
S_IFLNK
S_IFSOCK

int mknod(in 3char*, mode_t, dev_t);
*/

version (Linux) {
	enum S_IFMT     = 0xF000; // octal 0170000
	enum S_IFBLK    = 0x6000; // octal 0060000
	enum S_IFCHR    = 0x2000; // octal 0020000
	enum S_IFIFO    = 0x1000; // octal 0010000
	enum S_IFREG    = 0x8000; // octal 0100000
	enum S_IFDIR    = 0x4000; // octal 0040000
	enum S_IFLNK    = 0xA000; // octal 0120000
	enum S_IFSOCK   = 0xC000; // octal 0140000

	int mknod(in char*, mode_t, dev_t);
} else version (OSX) {
	enum S_IFMT     = 0xF000; // octal 0170000
	enum S_IFBLK    = 0x6000; // octal 0060000
	enum S_IFCHR    = 0x2000; // octal 0020000
	enum S_IFIFO    = 0x1000; // octal 0010000
	enum S_IFREG    = 0x8000; // octal 0100000
	enum S_IFDIR    = 0x4000; // octal 0040000
	enum S_IFLNK    = 0xA000; // octal 0120000
	enum S_IFSOCK   = 0xC000; // octal 0140000

	int mknod(in char*, mode_t, dev_t);
}
else version (FreeBSD) {
	enum S_IFMT     = 0xF000; // octal 0170000
	enum S_IFBLK    = 0x6000; // octal 0060000
	enum S_IFCHR    = 0x2000; // octal 0020000
	enum S_IFIFO    = 0x1000; // octal 0010000
	enum S_IFREG    = 0x8000; // octal 0100000
	enum S_IFDIR    = 0x4000; // octal 0040000
	enum S_IFLNK    = 0xA000; // octal 0120000
	enum S_IFSOCK   = 0xC000; // octal 0140000

	int mknod(in char*, mode_t, dev_t);
} else version(Solaris) {
	enum S_IFMT = 0xF000;
	enum S_IFBLK = 0x6000;
	enum S_IFCHR = 0x2000;
	enum S_IFIFO = 0x1000;
	enum S_IFREG = 0x8000;
	enum S_IFDIR = 0x4000;
	enum S_IFLNK = 0xA000;
	enum S_IFSOCK = 0xC000;

	int mknod(in char*, mode_t, dev_t);
} else {
	static assert(false, "Unsupported platform");
}
