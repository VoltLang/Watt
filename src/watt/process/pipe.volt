// Copyright © 2016, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.process.pipe;

version (Windows) {
	import core.windows.windows;
} else version (Posix) {
	import core.stdc.stdio;
}

import watt.process.cmd;
import watt.process.spawn;


version(Windows) {

	alias getOutput = getOutputWindows;

	/**
	 * Run the given command and read back the output into a string.
	 * Waits for the command to complete before returning.
	 */
	string getOutputWindows(string cmd, string[] args)
	{
		saAttr : SECURITY_ATTRIBUTES;
		hOut, hIn, hProcess : HANDLE;
		uRet : uint;
		bRet : BOOL;

		saAttr.nLength = cast(uint)typeid(saAttr).size;
		saAttr.bInheritHandle = true;
		saAttr.lpSecurityDescriptor = null;

		bRet = CreatePipe(&hIn, &hOut, &saAttr, 0);
		if (!bRet) {
			throw new ProcessException("Could not create pipe");
		}

		scope(exit) {
			CloseHandle(hIn);
			CloseHandle(hOut);
		}

		// Ensure the read handle to the pipe for STDOUT is not inherited.
		bRet = SetHandleInformation(hIn, HANDLE_FLAG_INHERIT, 0);
		if (!bRet) {
			throw new ProcessException("Failed to set hIn info");
		}

		// Use helpers to spawn.
		hProcess = spawnProcessWindows(cmd, args, null, hOut, null);
		scope(exit) {
			CloseHandle(hProcess);
		}

		// Wait for the process to close.
		uRet = WaitForSingleObject(hProcess, cast(DWORD)(-1));
		if (uRet) {
			throw new ProcessException("Failed to wait for program");
		}

		// Get the size of the output.
		sizeHigh : DWORD;
		sizeLow := GetFileSize(hIn, &sizeHigh);
		if (sizeHigh) {
			throw new ProcessException("Output is way to big");
		}

		// Read data from file.
		data := new void[](sizeLow);
		bRet = ReadFile(hIn, data.ptr, sizeLow, &uRet, null);

		// Check result of read.
		if (!bRet || uRet != data.length) {
			throw new ProcessException("Failed to read from output file");
		}

		return cast(string)data;
	}

}

version(Posix) {

	alias getOutput = getOutputPosix;

	/**
	 * Run the given command and read back the output into a string.
	 * Waits for the command to complete before returning.
	 */
	string getOutputPosix(string cmd, string[] args)
	{
		cmdPtr := toArgsPosix(cmd, args);
		fp := popen(cmdPtr, "r");
		if (fp is null) {
			throw new ProcessException("failed to launch the program");
		}

		size : size_t = 4096;
		buf := new char[](size);
		bytesRead := fread(cast(void*)buf.ptr, 1, size, fp);
		if (bytesRead > size) {
			throw new ProcessException("read failure.");
		}

		pclose(fp);

		return cast(string)buf[0 .. bytesRead];
	}

}
