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

VFLAGS ?= -I src
TARGET = libwatt.bc


########################################
# Setting up the source.
#

SRC = $(shell find src -name "*.v")
OBJ = $(patsubst src/%.v, $(OBJ_DIR)/%.bc, $(SRC))


########################################
# Targets.
#

all: $(TARGET)

$(TARGET): $(SRC) GNUmakefile
	@echo "  VOLT   $(TARGET)"
	@$(VOLT) --emit-bitcode -o $(TARGET) $(SRC)

clean:
	@rm -rf $(TARGET) .obj

.PHONY: all clean
