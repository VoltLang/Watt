// Copyright © 2011-2013, Jakob Bornecrantz.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module watt.library;


alias Loader = void* delegate(string);

version(Windows) {

	import core.windows.windows;

	// XXX Proper way to import this.
	extern(C)
	{
		HANDLE LoadLibraryA(const(char)* name);
		void* FreeLibrary(HANDLE lib);
		void* GetProcAddress(HANDLE lib, const(char)* name);
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
			return GetProcAddress(cast(HANDLE)ptr, symbol.ptr);
		}

		~this()
		{
			if (ptr !is null) {
				FreeLibrary(cast(HANDLE)ptr);
			}
			return;
		}

	} else version (Linux) {


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

		~this()
		{
			if (ptr !is null) {
				dlclose(ptr);
				ptr = null;
			}
			return;
		}

	} else version (OSX) {

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

		~this()
		{
			if (ptr !is null) {
				dlclose(ptr);
				ptr = null;
			}
			return;
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

	} else {

		static assert(false);

	}

private:
	this(void *ptr) { this.ptr = ptr; return; }
	void *ptr;
}
