// Copyright 2018, Collabora Ltd.
// SPDX-License-Identifier: BSL-1.0
module watt.process.sink;

import watt.text.sink;

import io = watt.io;

struct CStrSink
{
public:
	strStorage: char[16*1024];
	ptrStorage: char*[4*1024];
	strLoc: size_t;
	ptrLoc: size_t;


public:
	fn addArgz(str: SinkArg)
	{
		len := str.length + 1;
		if (!checkStorage(len)) {
			return;
		}

		ptrStorage[ptrLoc++] = &strStorage.ptr[strLoc];
		add(str, '\0');
	}

	fn addEnvz(key: SinkArg, value: SinkArg)
	{
		len := key.length + 1 + value.length + 1;
		if (!checkStorage(len)) {
			return;
		}

		ptrStorage[ptrLoc++] = &strStorage.ptr[strLoc];
		add(key, '=');
		add(value, '\0');
	}


private:
	fn checkStorage(len: size_t) bool
	{
		if (1 + ptrLoc >= ptrStorage.length) {
			return false;
		}

		if (len + strLoc >= strStorage.length) {
			return false;
		}

		return true;
	}

	fn add(str: SinkArg, c: char)
	{
		start := strLoc;
		end := strLoc + str.length;
		strStorage[start .. end] = str;
		strStorage[end] = c;

		strLoc = end + 1;
	}
}
