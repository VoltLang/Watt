# Makefile for windows.
# Intended for Digital Mars Make and GNU Make.

VOLT=volt
SRC=src\core\posix\sys\*.volt src\core\posix\*.volt src\core\stdc\*.volt src\core\windows\*.volt src\core\*.volt src\watt\*.volt src\watt\io\*.volt src\watt\text\*.volt src\watt\math\*.volt

all:
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-le32-emscripten.bc --arch le32 --platform emscripten $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86-linux.bc --arch x86 --platform linux $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86-mingw.bc --arch x86 --platform mingw $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86-osx.bc --arch x86 --platform osx $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86_64-linux.bc --arch x86_64 --platform linux $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86_64-mingw.bc --arch x86_64 --platform mingw $(SRC)
	$(VOLT) $(VFLAGS) -I src --emit-bitcode -o libwatt-x86_64-osx.bc --arch x86_64 --platform osx $(SRC)

clean:
	del /q *.bc
