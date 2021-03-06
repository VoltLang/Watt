// Copyright 2013, Jakob Bornecrantz.
// Copyright 2013, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
//! Functions for starting a process.
module watt.process.spawn;

version (Windows || Posix):

import core.exception;
import core.c.stdlib: csystem = system, exit, getenv;
import core.c.string: strlen;
import core.c.stdio;

version (Windows) {
	import core.c.windows.windows;
} else version (Posix) {
	import core.c.posix.sys.types: pid_t;
	import core.c.posix.unistd;
}

import watt.process.sink;
import watt.process.environment;

import watt.text.string: split;
import watt.text.format : format;
import watt.text.sink : StringSink;
import watt.io.file: exists;
import watt.io.streams.fd;
import watt.io.streams.stdc;
import watt.path: dirSeparator, pathSeparator;
import watt.conv;


/*!
 * Serves as a handle to a spawned process.
 *
 * Usually you will not construct these, but will get
 * them from @ref watt.process.spawn.spawnProcess.
 */
class Pid
{
public:
	version (Windows) {
		alias OsHandle = HANDLE;
		alias _handle = osHandle;
	} else version (Posix) {
		alias OsHandle = pid_t;
		alias _pid = osHandle;
	} else {
		alias OsHandle = int;
	}

	alias NativeID = OsHandle;


public:
	osHandle: OsHandle;


public:
	this(osHandle: OsHandle)
	{
		this.osHandle = osHandle;
	}

	/*!
	 * Wait for this process to finish, and get the return value.
	 */
	fn wait() i32
	{
		version (Posix) {
			return waitPosix(osHandle);
		} else version (Windows) {
			return waitWindows(osHandle);
		} else {
			return -1;
		}
	}
}

//! Thrown if a process could not be spawned.
class ProcessException : Exception
{
	this(msg: string)
	{
		super(msg);
	}
}

//! Search the current working directory and PATH for the given command.
fn getCommandFromName(name: string) string
{
	if (name is null) {
		throw new ProcessException("Name can not be null");
	}

	cmd: string;
	if (exists(name)) {
		cmd = name;
	} else {
		cmd = searchPath(name);
	}

	if (cmd is null) {
		throw new ProcessException(format("Can not find command %s", name));
	}

	return cmd;
}

version (CRuntime_All) {
/*!
 * Start a process from the executable `name` and with the given `args`.
 *
 * ### Example
 * ```volt
 * pid := spawnProcess("volta", ["-c", "test.volt"]);
 * pid.wait();  // Blocks until the process is finished.
 * ```
 */
fn spawnProcess(name: string, args: string[]) Pid
{
	return spawnProcess(name, args, stdin, stdout, stderr, null);
}
}

version (CRuntime_All) {
/*!
 * Start a process from an executable.
 *
 * @Param inputStream Standard input will be read from this stream. If this is
 * `null`, the system `STDIN` will be used.
 * @Param outputStream Standard output will be written to this stream. If this is `null`,
 * the system `STDOUT` will be used.
 * @Param errorStream Standard error will be written to this stream. If this is `null`,
 * the system `STDERR` will be used.
 * @Returns A `Pid` instance for the new process.
 * @Throws `ProcessException` if a process could not be spawned for some reason.
 */
fn spawnProcess(name: string, args: string[],
                inputStream:  InputStdcStream,
                outputStream: OutputStdcStream,
                errorStream:  OutputStdcStream,
                env: Environment = null) Pid
{
	stdinh  := inputStream is null ? null : inputStream.handle;
	stdouth := outputStream is null ? null : outputStream.handle;
	stderrh := errorStream is null ? null : errorStream.handle;
	return spawnProcess(name, args, stdinh, stdouth, stderrh, env);
}
}

version (Posix) {
/*!
 * Start a process from an executable.
 *
 * @Param inputStream Standard input will be read from this stream. If this is
 * `null`, the system `STDIN` will be used.
 * @Param outputStream Standard output will be written to this stream. If this is `null`,
 * the system `STDOUT` will be used.
 * @Param errorStream Standard error will be written to this stream. If this is `null`,
 * the system `STDERR` will be used.
 * @Returns A `Pid` instance for the new process.
 * @Throws `ProcessException` if a process could not be spawned for some reason.
 */
fn spawnProcess(name: string, args: string[],
                inputStream: InputFDStream,
                outputStream: OutputFDStream,
                errorStream: OutputFDStream,
                env: Environment = null) Pid
{
	cmd := getCommandFromName(name);
	stdinfd := inputStream is null ? STDIN_FILENO : inputStream.fd;
	stdoutfd := outputStream is null ? STDOUT_FILENO : outputStream.fd;
	stderrfd := errorStream is null ? STDERR_FILENO : errorStream.fd;
	pid := spawnProcessPosix(cmd, args, stdinfd, stdoutfd, stderrfd, env);
	return new Pid(pid);
}
}

version (Posix && CRuntime_All) {
/*
 * Start a process from an executable.
 *
 * Takes an optional environment, and input, output, and error streams.  
 * If the streams are null, stdin, stdout, and stderr respectively will be used.
 */
fn spawnProcess(name: string, args: string[],
                _stdin: FILE*,
                _stdout: FILE*,
                _stderr: FILE*,
                env: Environment = null) Pid
{
	cmd := getCommandFromName(name);
	stdinfd := _stdin is null ? fileno(stdin) : fileno(_stdin);
	stdoutfd := _stdout is null ? fileno(stdout) : fileno(_stdout);
	stderrfd := _stderr is null ? fileno(stderr) : fileno(_stderr);
	pid := spawnProcessPosix(cmd, args, stdinfd, stdoutfd, stderrfd, env);
	return new Pid(pid);
}
}

version (Windows && CRuntime_All) {
/*
 * Start a process from an executable.
 *
 * Takes an optional environment, and input, output, and error streams.  
 * If the streams are null, stdin, stdout, and stderr respectively will be used.
 */
fn spawnProcess(name: string, args: string[],
                _stdin: FILE*,
                _stdout: FILE*,
                _stderr: FILE*,
                env: Environment = null) Pid
{
	cmd := getCommandFromName(name);
	pid := spawnProcessWindows(cmd, args, _stdin, _stdout, _stderr, env);
	return new Pid(pid);
}
}

//! Search a PATH string for a command. If one is not given, PATH will be retrieved and used.
fn searchPath(cmd: string, path: string = null) string
{
	if (path is null) {
		path = getEnv("PATH");
	}
	if (path is null) {
		return null;
	}

	assert(pathSeparator.length == 1);

	foreach (p; split(path, pathSeparator[0])) {
		t := format("%s%s%s", p, dirSeparator, cmd);
		if (exists(t)) {
			return t;
		}
	}

	return null;
}

//! Get an environmental variable, or `""` if it doesn't exist.
fn getEnv(env: string) string
{
	ptr := getenv(toStringz(env));
	if (ptr is null) {
		return null;
	} else {
		return cast(string)ptr[0 .. strlen(ptr)];
	}
}

//! Run a command through the libc `system` function.
fn system(name: string) i32
{
	return csystem(toStringz(name));
}

version (Posix) {
	// Process spawning implementation for POSIX.
	fn spawnProcessPosix(name: string,
	                     args: string[],
	                     stdinFD: i32,
	                     stdoutFD: i32,
	                     stderrFD: i32,
	                     env: Environment) i32
	{
		argz: CStrSink;
		envz: CStrSink;

		// Fill out the envz to be given to execve, null safe.
		if (!envz.toEnvz(env)) {
			throw new ProcessException("Environment to large");
		}

		// Setup the argz to be given to execv[e].
		if (!argz.toArgz(name, args)) {
			throw new ProcessException("Out of argument memory");
		}

		pid := fork();
		if (pid != 0) {
			return pid;
		}

		// Child process

		// Redirect streams and close the old file descriptors.
		// In the case that stderr is redirected to stdout, we need
		// to backup the file descriptor since stdout may be redirected
		// as well.
		if (stderrFD == STDOUT_FILENO) {
			stderrFD = dup(stderrFD);
		}
		dup2(stdinFD,  STDIN_FILENO);
		dup2(stdoutFD, STDOUT_FILENO);
		dup2(stderrFD, STDERR_FILENO);

		// Close the old file descriptors, unless they are
		// either of the standard streams.
		if (stdinFD  > STDERR_FILENO) {
			close(stdinFD);
		}
		if (stdoutFD > STDERR_FILENO) {
			close(stdoutFD);
		}
		if (stderrFD > STDERR_FILENO) {
			close(stderrFD);
		}

		if (env is null) {
			execv(argz.ptrStorage[0], argz.ptrStorage.ptr);
		} else {
			execve(argz.ptrStorage[0], argz.ptrStorage.ptr, envz.ptrStorage.ptr);
		}
		exit(-1);
		assert(false);
	}

	//! Wait for a specific process.
	fn waitPosix(pid: pid_t) int
	{
		status: int;

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
	}

	//! Wait for a process.
	fn waitManyPosix(out pid: pid_t) i32
	{
		status, result: i32;

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
	}

	private fn toArgz(ref argz: CStrSink, name: string, args: string[]) bool
	{
		if (!argz.addArgz(name)) {
			return false;
		}

		foreach (arg; args) {
			if (!argz.addArgz(arg)) {
				return false;
			}
		}

		return true;
	}

	private fn toEnvz(ref envz: CStrSink, env: Environment) bool
	{
		if (env is null) {
			return true;
		}

		// Fill out the envz to be given to execve.
		foreach (k, v; env.store) {
			if (!envz.addEnvz(k, v)) {
				return false;
			}
		}

		return true;
	}

	private fn stopped(status: i32) bool { return (status & 0xff) == 0x7f; }
	private fn signaled(status: i32) bool { return ((((status & 0x7f) + 1) & 0xff) >> 1) > 0; }
	private fn exited(status: i32) bool { return (status & 0x7f) == 0; }

	private fn termsig(status: i32) i32 { return status & 0x7f; }
	private fn exitstatus(status: i32) i32 { return (status & 0xff00) >> 8; }

} else version (Windows) {

	private fn toArgz(moduleName: string, args: string[]) LPSTR
	{
		buffer: StringSink;
		buffer.sink("\"");
		buffer.sink(moduleName);
		foreach (arg; args) {
			buffer.sink("\" \"");
			buffer.sink(arg);
		}
		buffer.sink("\"\0");
		return cast(LPSTR)buffer.toString().ptr;
	}

	private fn toEnvz(stack: char[], env: Environment) void
	{
		start, end, resultPos: size_t;

		foreach (k, v; env.store) {
			// Will this pair fit.
			if (stack.length < end + k.length + v.length + 4) {
				break;
			}

			start = end;
			end = start + k.length;
			stack[start .. end] = k;
			stack[end++] = '=';

			if (v.length) {
				start = end;
				end = start + v.length;
				stack[start .. end] = v;
			}
			stack[end++] = '\0';
		}
		stack[end++] = '\0';
	}

	fn spawnProcessWindows(name: string, args: string[],
	                       stdinFP: FILE*,
	                       stdoutFP: FILE*,
	                       stderrFP: FILE*,
	                       env: Environment) HANDLE
	{
		fn stdHandle(file: FILE*, stdNo: DWORD) HANDLE {
			if (file !is null) {
				h := _get_osfhandle(_fileno(cast(void*)file));
				if (h !is cast(HANDLE)INVALID_HANDLE_VALUE) {
					return h;
				}
			}
			h := GetStdHandle(stdNo);
			if (h is cast(HANDLE)INVALID_HANDLE_VALUE) {
				throw new ProcessException("Couldn't get standard handle.");
			}
			return h;
		}

		hStdInput  := stdHandle(stdinFP,  STD_INPUT_HANDLE);
		hStdOutput := stdHandle(stdoutFP, STD_OUTPUT_HANDLE);
		hStdError  := stdHandle(stderrFP, STD_ERROR_HANDLE);

		return spawnProcessWindows(name, args, hStdInput, hStdOutput, hStdError, env);
	}

	fn spawnProcessWindows(name: string, args: string[],
	                       hStdIn: HANDLE,
	                       hStdOut: HANDLE,
	                       hStdErr: HANDLE,
	                       env: Environment) HANDLE
	{
		envStack: char[32_767];
		envPtr: LPVOID;

		si: STARTUPINFOA;
		si.cb = cast(DWORD) typeid(si).size;
		si.hStdInput  = hStdIn;
		si.hStdOutput = hStdOut;
		si.hStdError  = hStdErr;
		if ((si.hStdInput  !is null && si.hStdInput  !is cast(HANDLE)INVALID_HANDLE_VALUE) ||
		    (si.hStdOutput !is null && si.hStdOutput !is cast(HANDLE)INVALID_HANDLE_VALUE) ||
		    (si.hStdError  !is null && si.hStdError  !is cast(HANDLE)INVALID_HANDLE_VALUE)) {
			si.dwFlags = STARTF_USESTDHANDLES;
		}

		if (env !is null) {
			envPtr = cast(LPVOID)envStack.ptr;
			toEnvz(envStack, env);
		}

		pi: PROCESS_INFORMATION;

		moduleName := format("%s\0", name).ptr;
		bRet := CreateProcessA(moduleName, toArgz(name, args),
			null, null, TRUE, 0, envPtr, null, &si, &pi);

		if (bRet == 0) {
			throw new ProcessException(format("CreateProcess failed with error code %s", toString(cast(int)GetLastError())));
		}
		CloseHandle(pi.hThread);
		return pi.hProcess;
	}

	//! Wait for a HANDLE to finish.
	fn waitWindows(handle: HANDLE) i32
	{
		waitResult := WaitForSingleObject(handle, cast(u32) 0xFFFFFFFF);
		if (waitResult == cast(u32) 0xFFFFFFFF) {
			throw new ProcessException(format("WaitForSingleObject failed with error code %s", toString(cast(int)GetLastError())));
		}
		retval: DWORD;
		result := GetExitCodeProcess(handle, &retval);
		if (result == 0) {
			throw new ProcessException(format("GetExitCodeProcess failed with error code ", toString(cast(int)GetLastError())));
		}

		CloseHandle(handle);
		return cast(i32) retval;
	}
}
