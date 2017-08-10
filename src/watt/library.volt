// Copyright © 2011-2013, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
//! Load functions from shared objects.
module watt.library;

import watt.conv : toStringz;


alias Loader = dg (string) void*;

version(Windows) {

	import core.c.windows.windows;

	// XXX Proper way to import this.
	private extern(Windows)
	{
		fn LoadLibraryA(name: const(char)*) HMODULE;
		fn FreeLibrary(lib: HMODULE) void*;
		fn GetProcAddress(lib: HMODULE, name: const(char)*) void*;
	}

} else {

	// XXX Proper way to import this.
	private extern(C)
	{
		fn dlopen(file: const(char)*, mode: i32) void*;
		fn dlclose(handle: void*) i32;
		fn dlsym(handle: void*, name: const(char)*) void*;
		fn dlerror() char*;
	}

	enum RTLD_NOW    = 0x00002;
	enum RTLD_GLOBAL = 0x00100;

}

/*!
 * Represents a loadable module.
 */
class Library
{
private:
	version (Windows) {
		ptr: HMODULE;
	} else {
		ptr: void*;
	}

public:

	/*!
	 * Given a list of shared objects, return the first one that loads.
	 *
	 * @param files A list of shared objects to try and open.
	 * @return A `Library` instance from the first element of `files` that loads,
	 * or `null` if every element failed to load.
	 */
	global fn loads(files: string[]) Library
	{
		for (i: size_t; i < files.length; i++) {
			l := load(files[i]);
			if (l !is null) {
				return l;
			}
		}

		return null;
	}

	~this()
	{
		free();
	}

	version (Windows) {

		//! Create a Library from a path to a DLL.
		global fn load(filename: string) Library
		{
			ptr: void* = LoadLibraryA(toStringz(filename));

			if (ptr is null) {
				return null;
			}

			return new Library(ptr);
		}

		//! Return a pointer to the requested symbol name.
		final fn symbol(symbol: string) void*
		{
			return GetProcAddress(ptr, toStringz(symbol));
		}

		//! Release the library.
		final fn free()
		{
			if (ptr !is null) {
				FreeLibrary(ptr);
				ptr = null;
			}
		}

	} else version (Posix) {

		//! Create a Library from a path to a shared object.
		global fn load(filename: string) Library
		{
			p := dlopen(toStringz(filename), RTLD_NOW | RTLD_GLOBAL);

			if (p is null) {
				return null;
			}

			return new Library(p);
		}

		//! Return a pointer to the requested symbol name.
		final fn symbol(symbol: string) void*
		{
			return dlsym(ptr, toStringz(symbol));
		}

		//! Close the library.
		final fn free()
		{
			if (ptr !is null) {
				dlclose(ptr);
				ptr = null;
			}
		}

	} else {

		static assert(false);

	}

private:
	version (Windows) {
		this(ptr: HMODULE)
		{
			this.ptr = ptr;
		}
	} else {
		this(ptr: void*)
		{
			this.ptr = ptr;
		}
	}
}
