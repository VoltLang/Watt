########################################
# Find which compilers are installed.
#

VOLT ?= $(shell which volt)
HOST_UNAME := $(strip $(shell uname))
HOST_MACHINE := $(strip $(shell uname -m))
UNAME ?= $(HOST_UNAME)
MACHINE ?= $(HOST_MACHINE)

########################################
# Basic settings.
#

VFLAGS ?= --no-stdlib -I %@execdir%/rt/src
TARGETS = \
	bin/libwatt-le32-emscripten.bc \
	bin/libwatt-x86-mingw.bc \
	bin/libwatt-x86_64-mingw.bc \
	bin/libwatt-x86_64-msvc.bc \
	bin/libwatt-x86-linux.bc \
	bin/libwatt-x86_64-linux.bc \
	bin/libwatt-x86-osx.bc \
	bin/libwatt-x86_64-osx.bc

BIN_TARGETS = \
	bin/libwatt-x86-mingw.o \
	bin/libwatt-x86_64-mingw.o \
	bin/libwatt-x86_64-msvc.o \
	bin/libwatt-x86-linux.o \
	bin/libwatt-x86_64-linux.o \
	bin/libwatt-x86-osx.o \
	bin/libwatt-x86_64-osx.o


########################################
# Setting up the source.
#

SRC = $(shell find src -name "*.volt")
OBJ = $(patsubst src/%.v, $(OBJ_DIR)/%.bc, $(SRC))


########################################
# Targets.
#

all: $(TARGETS) $(BIN_TARGETS)

$(TARGETS): $(SRC) GNUmakefile
	@echo "  VOLT   $@"
	@mkdir -p bin
	@$(VOLT) $(VFLAGS) --emit-bitcode -o $@ -I src $(SRC) \
		--arch $(shell echo $@ | sed "s,bin/libwatt-\([^-]*\)-[^.]*.bc,\1,") \
		--platform $(shell echo $@ | sed "s,bin/libwatt-[^-]*-\([^.]*\).bc,\1,")

bin/%.o : bin/%.bc
	@echo "  VOLT   $@"
	@$(VOLT) $(VFLAGS) -c -o $@ $? \
		--arch $(shell echo $@ | sed "s,bin/libwatt-\([^-]*\)-[^.]*.o,\1,") \
		--platform $(shell echo $@ | sed "s,bin/libwatt-[^-]*-\([^.]*\).o,\1,")

clean:
	@rm -rf $(TARGETS) .obj
	@rm -rf bin
	@rm -rf .pkg
	@rm -rf watt.tar.gz	

package: all
	@mkdir -p .pkg
	@cp $(TARGETS) $(BIN_TARGETS) .pkg/
	@cp -r ./src/* .pkg/
	@tar -czf watt.tar.gz .pkg/*

.PHONY: all clean
