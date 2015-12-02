// Copyright © 2011-2013, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.library;


alias Loader = void* delegate(string);

version(Windows) {

	import core.windows.windows;

	// XXX Proper way to import this.
	extern(Windows)
	{
		HMODULE LoadLibraryA(const(char)* name);
		void* FreeLibrary(HMODULE lib);
		void* GetProcAddress(HMODULE lib, const(char)* name);
	}

} else {

	// XXX Proper way to import this.
	extern(C)
	{
		void *dlopen(const(char)* file, int mode);
		int dlclose(void* handle);
		void *dlsym(void* handle, const(char)* name);
		char* dlerror();
	}

	enum RTLD_NOW    = 0x00002;
	enum RTLD_GLOBAL = 0x00100;

}

class Library
{
private:
	version (Windows) {
		HMODULE ptr;
	} else {
		void* ptr;
	}

public:
	global Library loads(string[] files)
	{
		for (size_t i; i < files.length; i++) {
			auto l = load(files[i]);
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

		global Library load(string filename)
		{
			void *ptr = LoadLibraryA(filename.ptr);

			if (ptr is null) {
				return null;
			}

			return new Library(ptr);
		}

		final void* symbol(string symbol)
		{
			return GetProcAddress(ptr, symbol.ptr);
		}

		final void free()
		{
			if (ptr !is null) {
				FreeLibrary(ptr);
				ptr = null;
			}
		}

	} else version (Posix) {

		global Library load(string filename)
		{
			void *ptr = dlopen(filename.ptr, RTLD_NOW | RTLD_GLOBAL);

			if (ptr is null) {
				return null;
			}

			return new Library(ptr);
		}

		final void* symbol(string symbol)
		{
			return dlsym(ptr, symbol.ptr);
		}

		final void free()
		{
			if (ptr !is null) {
				dlclose(ptr);
				ptr = null;
			}
		}

	} else version (Emscripten) {

		global Library load(string filename)
		{
			throw new Exception("Huh oh! no impementation");
		}

		final void* symbol(string symbol)
		{
			throw new Exception("Huh oh! no impementation");
		}

		final void free()
		{
		}

	} else {

		static assert(false);

	}

private:
	version (Windows) {
		this(HMODULE ptr)
		{
			this.ptr = ptr;
		}
	} else {
		this(void* ptr)
		{
			this.ptr = ptr;
		}
	}
}
