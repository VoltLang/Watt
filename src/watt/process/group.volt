// Copyright 2012-2018, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
//! Launch and manage multiple processes.
module watt.process.group;

version (Windows || Posix):

import core.c.stdio : FILE;
import core.exception;

version(Windows) {
	import core.c.windows.windows;
} else {
	import core.c.posix.sys.types;
}

import watt.io.streams;
import watt.conv;
import watt.process;
import watt.text.format;

import io = watt.io;


/*!
 * Helper class to launch one or more processes
 * to run along side the main process.
 */
class Group
{
public:
	//! Is called with the retval of the completed command.
	alias DoneDg = dg (int);


private:
	//! All commands, commands are reused.
	cmdStore: Cmd[];

	//! For Windows waitOne, to avoid unneeded allocations.
	version (Windows) processHandles: Pid.OsHandle[];

	//! Number of simultanious jobs.
	maxWaiting: uint;

	//! Number of running jobs at this moment.
	waiting: uint;

	/*!
	 * Small container representing a executed command, is recycled.
	 */
	static class Cmd
	{
	public:
		//! Called when command has completed, with the return code.
		done: DoneDg;

		//! System specific process handle.
		handle: Pid.OsHandle;

		//! In use.
		used: bool;


	public:
		/*!
		 * Initialize all the fields.
		 */
		fn set(dgt: DoneDg, handle: Pid.OsHandle)
		{
			used = true;
			this.done = dgt;
			this.handle = handle;
		}

		/*!
		 * Reset to a unused state.
		 */
		fn reset()
		{
			used = false;
			done = null;
			version (Windows) {
				handle = null;
			} else {
				handle = 0;
			}
		}
	}


public:
	this(maxWaiting: uint)
	{
		this.maxWaiting = maxWaiting;

		cmdStore = new Cmd[](maxWaiting);
		version (Windows) processHandles = new Pid.OsHandle[](maxWaiting);

		foreach (ref cmd; cmdStore) {
			cmd = new Cmd();
		}
	}

	fn run(name: string, args: string[], done: DoneDg) Pid
	{
		// Wait until we have a free slot.
		while (waiting >= maxWaiting) {
			waitOne();
		}

		pid := spawnProcess(name, args, io.input, null, null, null);
		newCmd(done, pid);
		return pid;
	}

	version (CRuntime_All) fn run(
		name: string, args: string[],
		inputStream: InputStdcStream,
		outputStream: OutputStdcStream,
		errorStream: OutputStdcStream,
		env: Environment,
		done: DoneDg) Pid
	{
		// Wait until we have a free slot.
		while (waiting >= maxWaiting) {
			waitOne();
		}

		pid := spawnProcess(name, args, inputStream, outputStream, errorStream, env);
		newCmd(done, pid);
		return pid;
	}

	version (CRuntime_All) fn run(
		name: string, args: string[],
		inputStream: FILE*,
		outputStream: FILE*,
		errorStream: FILE*,
		env: Environment,
		done: DoneDg) Pid
	{
		// Wait until we have a free slot.
		while (waiting >= maxWaiting) {
			waitOne();
		}

		pid := spawnProcess(name, args, inputStream, outputStream, errorStream, env);
		newCmd(done, pid);
		return pid;
	}

	version (Posix) fn run(
		name: string, args: string[],
		inputStream: InputFDStream,
		outputStream: OutputFDStream,
		errorStream: OutputFDStream,
		env: Environment,
		done: DoneDg) Pid
	{
		// Wait until we have a free slot.
		while (waiting >= maxWaiting) {
			waitOne();
		}

		pid := spawnProcess(name, args, inputStream, outputStream, errorStream, env);
		newCmd(done, pid);
		return pid;
	}

	version (Posix) fn run(
		name: string, args: string[],
		inputFD: i32,
		outputFD: i32,
		errorFD: i32,
		env: Environment,
		done: DoneDg) Pid
	{
		// Wait until we have a free slot.
		while (waiting >= maxWaiting) {
			waitOne();
		}

		posixPid := spawnProcessPosix(name, args, inputFD, outputFD, errorFD, env);
		pid := new Pid(posixPid);
		newCmd(done, pid);
		return pid;
	}

	fn waitOne()
	{
		version(Windows) {
			hCount : uint;
			foreach (cmd; cmdStore) {
				if (cmd.used) {
					processHandles[hCount++] = cmd.handle;
				}
			}

			// If no cmds are running just return.
			if (hCount == 0) {
				return;
			}

			ptr := processHandles.ptr;
			uRet := WaitForMultipleObjects(hCount, ptr, FALSE, cast(uint)-1);
			if (uRet == cast(DWORD)-1 || uRet >= hCount) {
				throw new Exception(new "Wait failed with error code ${GetLastError()}");
			}

			hProcess := processHandles[uRet];

			// Retrieve the command for the returned wait, and remove it from the lists.
			c: Cmd;
			foreach (cmd; cmdStore) {
				if (hProcess !is cmd.handle) {
					continue;
				}
				c = cmd;
				break;
			}

			result: int = -1;
			bRet := GetExitCodeProcess(hProcess, cast(uint*)&result);
			cRet := CloseHandle(hProcess);
			if (bRet == 0) {
				c.reset();
				throw new Exception("Abnormal application termination");
			}
			if (cRet == 0) {
				throw new Exception(new "CloseHandle failed with error code ${GetLastError()}");
			}

		} else version(Posix) {
			result : int;
			pid : pid_t;

			// If no cmds are running just return.
			if (waiting == 0) {
				return;
			}

			result = waitManyPosix(out pid);

			c: Cmd;
			foreach (cmd; cmdStore) {
				if (cmd.handle != pid) {
					continue;
				}

				c = cmd;
				break;
			}

			if (c is null) {
				throw new Exception("PID waited on but not cleared!");
			}
		} else {
			static assert(false);
		}

		// But also reset it before calling the dgt
		dgt := c.done;

		c.reset();
		waiting--;

		if ((dgt !is null)) {
			dgt(result);
		}
	}

	/*!
	 * Wait for all currently dispatched processes to complete.
	 */
	fn waitAll()
	{
		while(waiting > 0) {
			waitOne();
		}
	}


private:
	fn newCmd(dgt: DoneDg, pid: Pid)
	{
		foreach (c; cmdStore) {
			if (c is null) {
				throw new Exception("null cmdStore");
			}
			if (!c.used) {
				c.set(dgt, pid.osHandle);
				waiting++;
				return;
			}
		}
		throw new Exception("newCmd failure");
	}
}
