// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module core.posix.spawn;

version (Linux || OSX):


import core.posix.sys.types;


enum u16 POSIX_SPAWN_RESETIDS           = 0x0001;
enum u16 POSIX_SPAWN_SETPGROUP          = 0x0002;
enum u16 POSIX_SPAWN_SETSIGDEF          = 0x0004;
enum u16 POSIX_SPAWN_SETSIGMASK         = 0x0008;


version (Linux) {

	enum u16 POSIX_SPAWN_SETSCHEDPARAM      = 0x0010;
	enum u16 POSIX_SPAWN_SETSCHEDULER       = 0x0020;
	enum u16 POSIX_SPAWN_USEVFORK           = 0x0040;

	version (X86) {

		struct posix_spawn_file_actions { void[76] __data; }
		struct posix_spawnattr { void[336] __data; }

	} else version (X86_64) {

		struct posix_spawn_file_actions { void[80] __data; }
		struct posix_spawnattr { void[336] __data; }

	} else {

		static assert(false, "arch not supported");
	}

	alias posix_spawn_file_actions_t = posix_spawn_file_actions;
	alias posix_spawnattr_t = posix_spawnattr;

} else version (OSX) {

	enum u16 POSIX_SPAWN_SETEXEC            = 0x0040;
	enum u16 POSIX_SPAWN_START_SUSPENDED    = 0x0080;
	enum u16 POSIX_SPAWN_CLOEXEC_DEFAULT    = 0x4000;

	struct posix_spawn_file_actions {}
	struct posix_spawnattr {}

	alias posix_spawn_file_actions_t = posix_spawn_file_actions*;
	alias posix_spawnattr_t = posix_spawnattr*;

} else {

	static assert(false, "not supported platform");

}


extern(C):

int posix_spawn(pid_t* pid, const(char)* path,
                const(posix_spawn_file_actions_t)* file_actions,
                const(posix_spawnattr_t)* attrp,
                const(char*)* argv, const(char*)* envp);
int posix_spawn(pid_t* pid, const(char)* file,
                const(posix_spawn_file_actions_t)* file_actions,
                const(posix_spawnattr_t)* attrp,
                const(char*)* argv, const(char*)* envp);


int posix_spawnattr_init(posix_spawnattr_t*);
int posix_spawnattr_destroy(posix_spawnattr_t*);
//int posix_spawnattr_getsigdefault(const(posix_spawnattr_t)*, sigset_t*);
//int posix_spawnattr_setsigdefault(posix_spawnattr_t*, const(sigset_t)*);
//int posix_spawnattr_getsigmask(const(posix_spawnattr_t)*, sigset_t*);
//int posix_spawnattr_setsigmask(posix_spawnattr_t*, const(sigset_t)*);
int posix_spawnattr_getflags(const(posix_spawnattr_t)*, i16*);
int posix_spawnattr_setflags(posix_spawnattr_t*, i16);
int posix_spawnattr_getpgroup (const(posix_spawnattr_t)*, pid_t*);
int posix_spawnattr_setpgroup (posix_spawnattr_t*, pid_t);
int posix_spawnattr_getschedpolicy (const(posix_spawnattr_t)*, int*);
int posix_spawnattr_setschedpolicy (posix_spawnattr_t*, int);
//int posix_spawnattr_getschedparam (const(posix_spawnattr_t)*, sched_param*,);
//int posix_spawnattr_setschedparam (posix_spawnattr_t*, const(sched_param)*);
int posix_spawn_file_actions_init (posix_spawn_file_actions_t*);
int posix_spawn_file_actions_destroy (posix_spawn_file_actions_t*);
int posix_spawn_file_actions_addopen (posix_spawn_file_actions_t*, int, const(char)*, int, mode_t);
int posix_spawn_file_actions_addclose (posix_spawn_file_actions_t*, int);
int posix_spawn_file_actions_adddup2 (posix_spawn_file_actions_t*, int, int);
