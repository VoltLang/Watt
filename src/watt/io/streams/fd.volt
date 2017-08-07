// Copyright © 2013-2017, Bernard Helyer.  All rights reserved.
// Copyright © 2016-2017, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Streams that interact with *nix FDs.
 */
module watt.io.streams.fd;

version (Posix):

import core.c.posix.fcntl : open, O_CREAT, O_WRONLY, O_RDONLY, O_TRUNC;
import core.c.posix.unistd : close, write, read;
import watt.algorithm : min;
import watt.conv : toStringz;
import watt.io.streams : OutputStream, InputStream;


/*!
 * Size of the internal read/write buffer.
 */
enum BufferSize = 1024;

/*!
 * An OutputStream in which the sink is a file.
 */
final class OutputFDStream : OutputStream
{
private:
	//! Always reserve one slot for put.
	enum Max = BufferSize - 1;
	mCur: size_t;
	mBuf: u8[BufferSize];


public:
	//! The file descriptor this stream wraps.
	fd: i32;


public:
	//! Construct a new @p OutputFDStream from a filename.
	this(filename: const(char)[])
	{
		if (filename.length <= 0) {
			fd = -1;
			return;
		}

		ptr := toStringz(filename);
		fd = .open(ptr, O_CREAT | O_TRUNC | O_WRONLY, 0x1B4 /* 664 */);
	}

	//! Close the underlying file descriptor.
	override fn close()
	{
		if (fd >= 0) {
			.close(fd);
			fd = -1;
		}
	}

	//! Is this a valid stream?
	@property override fn isOpen() bool
	{
		return fd >= 0;
	}

	//! Output @p c to the stream.
	override fn put(c: dchar)
	{
		// We can always put the char in the buffer.
		mBuf[mCur++] = cast(u8)c;

		if (mCur >= Max) {
			flush();
		}
	}

	//! Write @p s to the stream.
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

	//! Ensure that all buffered output is written.
	override fn flush()
	{
		if (mCur <= 0) {
			return;
		}

		.write(fd, cast(void*)mBuf.ptr, mCur);
		mCur = 0;
	}
}

/*!
 * An InputStream in which the source is a file.
 */
class InputFDStream : InputStream
{
private:
	mBuf: u8[BufferSize];
	mStart: size_t;
	mCur: size_t;


public:
	//! The underlying file descriptor.
	fd: i32;


public:
	//! Construct a new @p InputFDStream from a filename.
	this(filename: const(char)[])
	{
		if (filename.length <= 0) {
			fd = -1;
			return;
		}

		ptr := toStringz(filename);
		fd = .open(ptr, O_CREAT | O_RDONLY, 0x1B4 /* 664 */);
	}

	//! Close the underlying file descriptor.
	override fn close()
	{
		if (fd >= 0) {
			.close(fd);
			fd = -1;
		}
	}

	//! Is this wrapping a valid file descriptor?
	@property override fn isOpen() bool
	{
		return fd >= 0;
	}

	//! Read the first character from the file descriptor.
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

	/*!
	 * Read from the stream into @p buffer.
	 *
	 * @Returns A slice of the buffer actually used.
	 */
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

	//! Has this descriptor reached EOF?
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
