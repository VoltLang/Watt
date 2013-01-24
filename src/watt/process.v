// Copyright © 2013, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/license.d (BOOST ver. 1.0).
module watt.process;


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
	version (Posix) {
		auto pid = spawnProcessPosix(name, args, 1, 2, 3);
	} else {
		int pid;
	}

	return new Pid(pid);
}

version (Posix) private
{
	extern(C) int execvp(char* file, char** argv);
	extern(C) int fork();

	int spawnProcessPosix(string name,
	                      string[] args,
	                      int stdin_,
	                      int stdout_,
	                      int stderr_)
	{
		auto stack = new char[16384];
		auto argz = new char*[4096];

		toArgz(stack[], argz[], name, args);

		auto pid = fork();
		if (pid != 0)
			return pid;

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
