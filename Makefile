# Makefile for windows.
# Intended for Digital Mars Make and GNU Make.

VOLT=volt
SRC=src\watt\*.volt src\watt\io\*.volt src\watt\io\streams\*.volt src\watt\text\*.volt src\watt\math\*.volt src\watt\json\*.volt src\watt\markdown\*.volt src\watt\process\*.volt src\watt\http\*.volt

all:
	mkdir bin
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86-linux.bc --arch x86 --platform linux $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86-mingw.bc --arch x86 --platform mingw $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86-osx.bc --arch x86 --platform osx $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86_64-linux.bc --arch x86_64 --platform linux $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86_64-mingw.bc --arch x86_64 --platform mingw $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86_64-msvc.bc --arch x86_64 --platform msvc $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o bin\libwatt-x86_64-osx.bc --arch x86_64 --platform osx $(SRC)
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86-linux.o  --arch x86 --platform linux bin\libwatt-x86-linux.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86-mingw.o  --arch x86 --platform mingw bin\libwatt-x86-mingw.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86-osx.o --arch x86 --platform osx bin\libwatt-x86-osx.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86_64-linux.o --arch x86_64 --platform linux bin\libwatt-x86_64-linux.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86_64-mingw.o --arch x86_64 --platform mingw bin\libwatt-x86_64-mingw.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86_64-msvc.o --arch x86_64 --platform msvc bin\libwatt-x86_64-msvc.bc
	$(VOLT) $(VFLAGS) -I src -c -o bin\libwatt-x86_64-osx.o  --arch x86_64 --platform osx bin\libwatt-x86_64-osx.bc

clean:
	del /q bin
