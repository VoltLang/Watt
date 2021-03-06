// Copyright 2016, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
//! Functions for dealing with pipes.
module watt.process.pipe;

version (Windows || Posix):

version (Windows) {
	import core.c.windows.windows;
} else version (Posix) {
	import core.c.stdio;
	import core.c.posix.sys.wait : WEXITSTATUS;
}

import watt.text.sink;
import watt.process.cmd;
import watt.process.spawn;

enum BufferSize = 1024;


version(Windows) {

	/*!
	 * Run the given command and read back the output/error into a string.
	 *
	 * Waits for the command to complete before returning.
	 *
	 * @{
	 */
	fn getOutput(cmd: string, args: string[]) string
	{
		dummy: u32;
		return getOutputWindows(cmd, args, ref dummy);
	}

	fn getOutput(cmd: string, args: string[], ref retval: u32) string
	{
		return getOutputWindows(cmd, args, ref retval);
	}
	//! @}

	private fn getOutputWindows(cmd: string, args: string[], ref retval: u32) string
	{
		ss: StringSink;
		saAttr: SECURITY_ATTRIBUTES;
		hPipeWrite, hPipeRead, hProcess: HANDLE;
		uRet: u32;
		bRet: BOOL;

		saAttr.nLength = cast(u32)typeid(saAttr).size;
		saAttr.bInheritHandle = true;
		saAttr.lpSecurityDescriptor = null;

		bRet = CreatePipe(&hPipeRead, &hPipeWrite, &saAttr, 0);
		if (!bRet) {
			throw new ProcessException("Could not create pipe");
		}

		scope(exit) {
			CloseHandle(hPipeRead);
		}

		// Ensure the read handle to the pipe for STDOUT is not inherited.
		bRet = SetHandleInformation(hPipeRead, HANDLE_FLAG_INHERIT, 0);
		if (!bRet) {
			throw new ProcessException("Failed to set hPipeRead info");
		}

		// Use helpers to spawn.
		hProcess = spawnProcessWindows(cmd, args, null, hPipeWrite, hPipeWrite, null);
		scope(exit) {
			dwRetval: DWORD;
			if (GetExitCodeProcess(hProcess, &dwRetval) != 0) {
				retval = cast(u32)dwRetval;
			}
			CloseHandle(hProcess);
		}

		CloseHandle(hPipeWrite);  // Otherwise ReadFile will hang as the pipe could be written to.
		while (true) {
			data: char[BufferSize];
			bRet = ReadFile(hPipeRead, cast(void*)data.ptr, BufferSize, &uRet, null);
			if (!bRet || uRet == 0) {
				break;
			}
			ss.sink(data[0 .. uRet]);
		}

		return ss.toString();
	}

}

version(Posix) {
	import watt.conv;
	/*!
	 * Run the given command and read back the output/error into a string.
	 *
	 * Waits for the command to complete before returning.
	 *
	 * @{
	 */
	fn getOutput(cmd: string, args: string[]) string
	{
		dummy: u32;
		return getOutputPosix(cmd, args, ref dummy);
	}

	fn getOutput(cmd: string, args: string[], ref retval: u32) string
	{
		return getOutputPosix(cmd, args, ref retval);
	}
	//! @}

	private fn getOutputPosix(cmd: string, args: string[], ref retval: u32) string
	{
		ss: StringSink;
		cmdPtr := toArgsPosix(cmd, args, "2>&1");
		fp := popen(cmdPtr, "r");
		if (fp is null) {
			throw new ProcessException("failed to launch the program");
		}

		buf: char[BufferSize];
		while (true) {
			bytesRead := fread(cast(void*)buf.ptr, 1, BufferSize, fp);
			if (bytesRead > BufferSize || (bytesRead == 0 && ferror(fp) != 0)) {
				throw new ProcessException("read failure");
			}
			if (bytesRead == 0) {
				break;
			}
			ss.sink(buf[0 .. bytesRead]);
		}

		retval = cast(u32)WEXITSTATUS(pclose(fp));

		return ss.toString();
	}
}
