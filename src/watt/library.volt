// Copyright © 2011-2013, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.library;


alias Loader = void* delegate(string);

version(Windows) {

	import core.windows.windows;

	// XXX Proper way to import this.
	extern(Windows)
	{
		fn LoadLibraryA(name : const(char)*) HMODULE;
		fn FreeLibrary(lib : HMODULE) void*;
		fn GetProcAddress(lib : HMODULE, name : const(char)*) void*;
	}

} else {

	// XXX Proper way to import this.
	extern(C)
	{
		fn dlopen(file : const(char)*, mode : i32) void*;
		fn dlclose(handle : void*) i32;
		fn dlsym(handle : void*, name : const(char)*) void*;
		fn dlerror() char*;
	}

	enum RTLD_NOW    = 0x00002;
	enum RTLD_GLOBAL = 0x00100;

}

class Library
{
private:
	version (Windows) {
		ptr : HMODULE;
	} else {
		ptr : void*;
	}

public:
	global fn loads(files : string[]) Library
	{
		for (i : size_t; i < files.length; i++) {
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

		global fn load(filename : string) Library
		{
			ptr : void* = LoadLibraryA(filename.ptr);

			if (ptr is null) {
				return null;
			}

			return new Library(ptr);
		}

		final fn symbol(symbol : string) void*
		{
			return GetProcAddress(ptr, symbol.ptr);
		}

		final fn free()
		{
			if (ptr !is null) {
				FreeLibrary(ptr);
				ptr = null;
			}
		}

	} else version (Posix) {

		global fn load(filename : string) Library
		{
			ptr : void* = dlopen(filename.ptr, RTLD_NOW | RTLD_GLOBAL);

			if (ptr is null) {
				return null;
			}

			return new Library(ptr);
		}

		final fn symbol(symbol : string) void*
		{
			return dlsym(ptr, symbol.ptr);
		}

		final fn free()
		{
			if (ptr !is null) {
				dlclose(ptr);
				ptr = null;
			}
		}

	} else version (Emscripten) {

		global fn load(filename : string) Library
		{
			return null;
		}

		final fn symbol(symbol : string) void*
		{
			return null;
		}

		final fn free()
		{
		}

	} else {

		static assert(false);

	}

private:
	version (Windows) {
		this(ptr : HMODULE)
		{
			this.ptr = ptr;
		}
	} else {
		this(ptr : void*)
		{
			this.ptr = ptr;
		}
	}
}
