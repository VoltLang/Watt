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
	libwatt-le32-emscripten.bc \
	libwatt-x86-mingw.bc \
	libwatt-x86_64-mingw.bc \
	libwatt-x86_64-msvc.bc \
	libwatt-x86-linux.bc \
	libwatt-x86_64-linux.bc \
	libwatt-x86-osx.bc \
	libwatt-x86_64-osx.bc


########################################
# Setting up the source.
#

SRC = $(shell find src -name "*.volt")
OBJ = $(patsubst src/%.v, $(OBJ_DIR)/%.bc, $(SRC))


########################################
# Targets.
#

all: $(TARGETS)

$(TARGETS): $(SRC) GNUmakefile
	@echo "  VOLT   $@"
	@$(VOLT) $(VFLAGS) --emit-bitcode -o $@ -I src $(SRC) \
		--arch $(shell echo $@ | sed "s,libwatt-\([^-]*\)-[^.]*.bc,\1,") \
		--platform $(shell echo $@ | sed "s,libwatt-[^-]*-\([^.]*\).bc,\1,")

clean:
	@rm -rf $(TARGETS) .obj
	@rm -rf .pkg
	@rm -rf watt.tar.gz	

package: all
	@mkdir -p .pkg
	@cp $(TARGETS) .pkg/
	@cp -r ./src/* .pkg/
	@tar -czf watt.tar.gz .pkg/*

.PHONY: all clean
