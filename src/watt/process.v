// Copyright © 2013, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
module watt.process;

import core.stdc.stdio;

class Pid
{
	int _pid;
	this(int pid)
	{
		this._pid = pid;
		return;
	}
}

Pid spawnProcess(string name, string[] args)
{	
	return spawnProcessFiles(name, args, stdin, stdout, stderr);
}

/**
 * Rename when overloading works, merge when default
 * arguments work.
 */
Pid spawnProcessFiles(string name, string[] args,
                      FILE* _stdin,
                      FILE* _stdout,
                      FILE* _stderr)
{
	version (Posix) {
		auto pid = spawnProcessPosix(name, args, fileno(_stdin), fileno(_stdout), fileno(_stderr));
	} else {
		int pid;
	}

	return new Pid(pid);
}

version (Posix) private {

	extern(C) int execvp(char* file, char** argv);
	extern(C) int fork();
	extern(C) int dup(int);
	extern(C) int dup2(int, int);
	extern(C) void close(int);

	int spawnProcessPosix(string name,
	                      string[] args,
	                      int stdinFD,
	                      int stdoutFD,
	                      int stderrFD)
	{
		auto stack = new char[16384];
		auto argz = new char*[4096];

		// Remove these when enums work.
		int STDOUT_FILENO = 1;
		int STDIN_FILENO = 2;
		int STDERR_FILENO = 3;

		toArgz(stack[], argz[], name, args);

		auto pid = fork();
		if (pid != 0)
			return pid;

		// Child process

		// Redirect streams and close the old file descriptors.
		// In the case that stderr is redirected to stdout, we need
		// to backup the file descriptor since stdout may be redirected
		// as well.
		if (stderrFD == STDOUT_FILENO)
			stderrFD = dup(stderrFD);
		dup2(stdinFD,  STDIN_FILENO);
		dup2(stdoutFD, STDOUT_FILENO);
		dup2(stderrFD, STDERR_FILENO);

		// Close the old file descriptors, unless they are
		// either of the standard streams.
		if (stdinFD  > STDERR_FILENO)
			close(stdinFD);
		if (stdoutFD > STDERR_FILENO)
			close(stdoutFD);
		if (stderrFD > STDERR_FILENO)
			close(stderrFD);

		execvp(argz[0], &argz[0]);
		return 0;
	}

	void toArgz(char[] stack, char*[] result, string name, string[] args)
	{
		size_t resultPos;

		result[resultPos++] = stack.ptr;
		stack[0 .. name.length] = name;
		stack[name.length] = cast(char)0;

		stack = stack[name.length + 1u .. stack.length];

		for (uint i; i < args.length; i++) {
			result[resultPos++] = stack.ptr;

			auto arg = args[i];
			stack[0 .. arg.length] = arg;
			stack[arg.length] = cast(char)0;

			stack = stack[arg.length + 1u .. stack.length];
		}

		return;
	}

}
