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
TARGET = libwatt.bc


########################################
# Setting up the source.
#

SRC = $(shell find src -name "*.volt")
OBJ = $(patsubst src/%.v, $(OBJ_DIR)/%.bc, $(SRC))


########################################
# Targets.
#

all: $(TARGET)

$(TARGET): $(SRC) GNUmakefile
	@echo "  VOLT   $(TARGET)"
	@$(VOLT) $(VFLAGS) --emit-bitcode -o $(TARGET) -I src $(SRC)

clean:
	@rm -rf $(TARGET) .obj
	@rm -rf .pkg
	@rm -rf watt.tar.gz	

package: all
	@mkdir -p .pkg
	@cp libwatt.bc .pkg/
	@cp -r ./src/* .pkg/
	@tar -czf watt.tar.gz .pkg/*

.PHONY: all clean
