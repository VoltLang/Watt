// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.io.streams.fd;

version (Posix):

import core.c.posix.fcntl : open, O_CREAT, O_WRONLY, O_RDONLY, O_TRUNC;
import core.c.posix.unistd : close, write, read;
import watt.algorithm : min;
import watt.conv : toStringz;
import watt.io.streams : OutputStream, InputStream;


/**
 * Size of the internal read/write buffer.
 */
enum BufferSize = 1024;

/**
 * An OutputStream in which the sink is a file.
 */
final class OutputFDStream : OutputStream
{
private:
	/// Always reserve one slot for put.
	enum Max = BufferSize - 1;
	mCur: size_t;
	mBuf: u8[BufferSize];


public:
	fd: i32;


public:
	this(filename: const(char)[])
	{
		if (filename.length <= 0) {
			fd = -1;
			return;
		}

		ptr := toStringz(filename);
		fd = .open(ptr, O_CREAT | O_TRUNC | O_WRONLY, 0x1B4 /* 664 */);
	}

	override fn close()
	{
		if (fd >= 0) {
			.close(fd);
			fd = -1;
		}
	}

	@property override fn isOpen() bool
	{
		return fd >= 0;
	}

	override fn put(c: dchar)
	{
		// We can always put the char in the buffer.
		mBuf[mCur++] = cast(u8)c;

		if (mCur >= Max) {
			flush();
		}
	}

	override fn write(s: scope const(char)[])
	{
		ptr := cast(u8*)s.ptr;
		size := s.length;
		if (s.length + mCur < Max) {
			mBuf[mCur .. mCur + size] = ptr[0 .. size];
			mCur += size;
		} else {
			flush();
			.write(fd, cast(void*)ptr, size);
		}
	}

	override fn flush()
	{
		if (mCur <= 0) {
			return;
		}

		.write(fd, cast(void*)mBuf.ptr, mCur);
		mCur = 0;
	}
}

/**
 * An InputStream in which the source is a file.
 */
class InputFDStream : InputStream
{
private:
	mBuf: u8[BufferSize];
	mStart: size_t;
	mCur: size_t;


public:
	fd: i32;


public:
	this(filename: const(char)[])
	{
		if (filename.length <= 0) {
			fd = -1;
			return;
		}

		ptr := toStringz(filename);
		fd = .open(ptr, O_CREAT | O_RDONLY, 0x1B4 /* 664 */);
	}

	override fn close()
	{
		if (fd >= 0) {
			.close(fd);
			fd = -1;
		}
	}

	@property override fn isOpen() bool
	{
		return fd >= 0;
	}

	override fn get() dchar
	{
		if (mStart >= mCur) {
			fillBuffer();
		}
		if (mStart < mCur) {
			return mBuf[mStart++];
		} else {
			return cast(dchar)-1;
		}
	}

	override fn read(buffer: u8[]) u8[]
	{
		used: size_t;
		if (mStart < mCur) {
			used = min(mCur - mStart, buffer.length);
			buffer[0 .. used] = mBuf[mStart .. mStart + used];
			if (used >= mCur - mStart) {
				mCur = 0;
				mStart = 0;
			} else {
				mStart += used;
			}
		}

		if (used >= buffer.length) {
			return buffer[0 .. used];
		}

		ret := .read(fd, cast(void*)&buffer[used], buffer.length - used);
		if (ret <= 0) {
			return buffer[0 .. used];
		}

		used += cast(size_t)ret;
		return buffer[0 .. used];
	}

	override fn eof() bool
	{
		if (mStart < mCur) {
			return false;
		}
		return fillBuffer() == 0;
	}


private:
	fn fillBuffer() size_t
	{
		ret := .read(fd, cast(void*)mBuf.ptr, mBuf.length);
		mStart = 0;
		mCur = ret <= 0 ? cast(size_t)0 : cast(size_t)ret;
		return mCur;
	}
}
