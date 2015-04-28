// Copyright © 2013, Jakob Bornecrantz.
// Copyright © 2013, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process;

import core.stdc.stdlib : csystem = system;
import core.stdc.stdio;
version (Windows) {
	import core.windows.windows;
} else version (Posix) {
	import core.posix.sys.types : pid_t;
}

import watt.conv;

class Pid
{
private:
	version (Windows) {
		HANDLE _handle;
	} else version (Posix) {
		pid_t _pid;
	} else {
		// Nothing
	}

public:
	version (Windows) {
		this(HANDLE handle)
		{
			this._handle = handle;
			return;
		}
	} else version (Posix) {
		this(pid_t pid)
		{
			this._pid = pid;
			return;
		}
	} else {
		this(int pid)
		{
			return;
		}
	}

	int wait()
	{
		version (Posix) {
			return waitPosix(_pid);
		} else version (Windows) {
			return waitWindows(_handle);
		} else {
			return -1;
		}
	}
}

class ProcessException : object.Exception
{
	this(string msg)
	{
		super(msg);
		return;
	}
}

Pid spawnProcess(string name, string[] args)
{
	return spawnProcess(name, args, stdin, stdout, stderr);
}

Pid spawnProcess(string name, string[] args,
                 FILE* _stdin,
                 FILE* _stdout,
                 FILE* _stderr)
{
	version (Posix) {
		auto pid = spawnProcessPosix(name, args, fileno(_stdin), fileno(_stdout), fileno(_stderr));
	} else version (Windows) {
		auto pid = spawnProcessWindows(name, args, _stdin, _stdout, _stderr);
	} else {
		int pid;
	}

	return new Pid(pid);
}

private {
	extern(C) char* getenv(in char*);
	extern(C) size_t strlen(in char*);
}

string getEnv(string env)
{
	auto ptr = getenv(env.ptr);
	if (ptr is null) {
		return null;
	} else {
		return cast(string)ptr[0 .. strlen(ptr)];
	}
}

int system(string name)
{
	return csystem(toStringz(name));
}

version (Posix) private {

	extern(C) int execvp(char* file, char** argv);
	extern(C) pid_t fork();
	extern(C) int dup(int);
	extern(C) int dup2(int, int);
	extern(C) void close(int);
	extern(C) pid_t waitpid(pid_t, int*, int);
	extern(C) void exit(int);

	int spawnProcessPosix(string name,
	                      string[] args,
	                      int stdinFD,
	                      int stdoutFD,
	                      int stderrFD)
	{
		auto stack = new char[](16384);
		auto argz = new char*[](4096);

		// Remove these when enums work.
		int STDIN_FILENO = 0;
		int STDOUT_FILENO = 1;
		int STDERR_FILENO = 2;

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
		exit(-1);
		assert(false);
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

		// Zero the last argument.
		result[resultPos] = null;

		return;
	}

	int waitPosix(pid_t pid)
	{
		int status;

		// Because stopped processes doesn't count.
		while(true) {
			pid = waitpid(pid, &status, 0);

			if (exited(status)) {
				return exitstatus(status);
			} else if (signaled(status)) {
				return -termsig(status);
			} else if (stopped(status)) {
				continue;
			} else {
				return -1;//errno();
			}
		}
		assert(false);
	}

	int waitManyPosix(out pid_t pid)
	{
		int status, result;

		// Because stopped processes doesn't count.
		while(true) {
			pid = waitpid(-1, &status, 0);

			if (exited(status)) {
				result = exitstatus(status);
			} else if (signaled(status)) {
				result = -termsig(status);
			} else if (stopped(status)) {
				continue;
			} else {
				result = -1; // TODO errno
			}

			return result;
		}
		assert(false);
	}

	bool stopped(int status)  { return (status & 0xff) == 0x7f; }
	bool signaled(int status) { return ((((status & 0x7f) + 1) & 0xff) >> 1) > 0; }
	bool exited(int status)   { return (status & 0x7f) == 0; }

	int termsig(int status)    { return status & 0x7f; }
	int exitstatus(int status) { return (status & 0xff00) >> 8; }
} else version (Windows) {
	extern (C) int _fileno(FILE* stream);
	extern (C) HANDLE _get_osfhandle(int fd);
	
	LPSTR toArgz(string moduleName, string[] args)
	{
		char[] buffer;
		for (size_t i = 0; i < args.length; i++) {
			buffer ~= ' ';
			buffer ~= cast(char[]) args[i];
		}
		buffer ~= '\0';
		return buffer.ptr;
	}

	HANDLE spawnProcessWindows(string name, string[] args, FILE* stdinFP, FILE* stdoutFP, FILE* stderrFP)
	{
		STARTUPINFOA si;
		si.cb = cast(DWORD) typeid(si).size;
		si.dwFlags = STARTF_USESTDHANDLES;
		si.hStdInput = _get_osfhandle(_fileno(stdinFP));
		si.hStdOutput = _get_osfhandle(_fileno(stdoutFP));
		si.hStdError = _get_osfhandle(_fileno(stderrFP));

		PROCESS_INFORMATION pi;

		auto moduleName = name ~ '\0';
		BOOL bRet = CreateProcessA(moduleName.ptr, toArgz(moduleName, args), null, null, FALSE, 0, null, null, &si, &pi);
		if (bRet == 0) {
			throw new ProcessException("CreateProcess failed with error code " ~ toString(cast(int)GetLastError()));
		}
		CloseHandle(pi.hThread);
		return pi.hProcess;
	}

	int waitWindows(HANDLE handle)
	{
		DWORD waitResult = WaitForSingleObject(handle, cast(uint) 0xFFFFFFFF);
		if (waitResult == cast(uint) 0xFFFFFFFF) {
			throw new ProcessException("WaitForSingleObject failed with error code " ~ toString(cast(int)GetLastError()));
		}
		DWORD retval;
		BOOL result = GetExitCodeProcess(handle, &retval);
		if (result == 0) {
			throw new ProcessException("GetExitCodeProcess failed with error code " ~ toString(cast(int)GetLastError()));
		}

		CloseHandle(handle);
		return cast(WORD) retval;
	}
}
