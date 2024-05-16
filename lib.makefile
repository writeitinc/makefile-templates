# This Makefile is based on a template (lib.makefile version 4.0.0).
# See: https://github.com/writeitinc/makefile-templates

NAME = # give it a name!

ifndef NAME
$(error NAME is not set)
endif

#### Commandline Control Flags #################################################

BUILD_TYPE = $(DEFAULT_BUILD_TYPE)
CFLAGS = $(CFLAGS_DEFAULT)
LDFLAGS = $(LTOFLAGS)
LTOFLAGS = -flto=auto
DEFINES = # none by default

USE_WINDOWS_CMD = # guess by default
PRODUCE_WINDOWS_OUTPUTS = # guess by default

#### General Build Config ######################################################

DEFAULT_BUILD_TYPE = release # release, debug, or sanitize
CSTD = c99

# Flags #

CFLAGS_DEFAULT = $(OPTIM) $(WFLAGS)
WFLAGS = -Wall -Wextra -Wpedantic -std=$(CSTD)

OPTIM = $(OPTIM_$(BUILD_TYPE))
OPTIM_release = -O2
OPTIM_debug = -g
OPTIM_sanitize = $(OPTIM_debug)

SANITIZE_FLAGS = $(SANITIZE_FLAGS_$(BUILD_TYPE))
SANITIZE_FLAGS_release =
SANITIZE_FLAGS_debug =
SANITIZE_FLAGS_sanitize = -fsanitize=address,undefined

STATIC_LIB_FLAGS =
SHARED_LIB_FLAGS = $(PLATFORM_SHARED_LIB_FLAGS)

# Output Directories #

OUTPUT_DIR = build

LIB_DIR = $(OUTPUT_DIR)/lib
BIN_DIR = $(OUTPUT_DIR)/bin
INTERMEDIATE_DIR = $(OUTPUT_DIR)/obj

#### Library Build Config ######################################################

# Inputs #

SOURCE_DIR = src
INCLUDE_DIR = include
HEADER_DIR = $(INCLUDE_DIR)/$(NAME)

SOURCES = $(wildcard $(SOURCE_DIR)/*.c)
HEADERS = $(wildcard $(HEADER_DIR)/*.h)

# Outputs #

LIBRARIES = $(STATIC_LIB) $(SHARED_LIB)
STATIC_LIB = $(LIB_DIR)/$(LIB_PREFIX)$(NAME).a
SHARED_LIB = $(LIB_DIR)/$(LIB_PREFIX)$(NAME)$(SHARED_LIB_EXT)

# Intermediates #

STATIC_OBJS = $(patsubst $(SOURCE_DIR)/%.c, $(INTERMEDIATE_DIR)/%.static.o, $(SOURCES))
SHARED_OBJS = $(patsubst $(SOURCE_DIR)/%.c, $(INTERMEDIATE_DIR)/%.shared.o, $(SOURCES))
.SECONDARY: $(STATIC_OBJS) $(SHARED_OBJS)

#### Platform/Toolchain Detection ##############################################

ifeq ($(OS),Windows_NT)
USE_WINDOWS_CMD = true
PRODUCE_WINDOWS_OUTPUTS = true
else # assume linux host & target
USE_WINDOWS_CMD = false
PRODUCE_WINDOWS_OUTPUTS = false
endif

ifeq ($(USE_WINDOWS_CMD),true)
MKDIR_P = if not exist $(subst /,\,$(1)) mkdir $(subst /,\,$(1))
RM_RF = del /S /Q $(subst /,\,$(1))
else # use posix shell
MKDIR_P = mkdir -p $(1)
RM_RF = rm -rf $(1)
endif

ifeq ($(PRODUCE_WINDOWS_OUTPUTS),true)
LIB_PREFIX =
SHARED_LIB_EXT = .dll
EXEC_EXT = .exe # NOTE: mingw will produce a file named *.exe regardless

PLATFORM_SHARED_LIB_FLAGS = -Wl,--out-implib,$(@:dll=lib)
else # produce linux outputs
LIB_PREFIX = lib
SHARED_LIB_EXT = .so
EXEC_EXT =

PLATFORM_SHARED_LIB_FLAGS = -fPIC -fvisibility=hidden
endif

#### Make Targets ##############################################################

### General ###

.PHONY: default
default: $(DEFAULT_BUILD_TYPE)

.PHONY: release
release: BUILD_TYPE = release
release: output-dirs
release: $(LIBRARIES)

.PHONY: debug
debug: BUILD_TYPE = debug
debug: output-dirs
debug: $(LIBRARIES)

.PHONY: sanitize
sanitize: BUILD_TYPE = sanitize
sanitize: output-dirs
sanitize: $(LIBRARIES)

# Pro Tip: DO NOT EVER run `rm -rf` (or similar) on a variable
.PHONY: clean
clean:
	$(call RM_RF,build/*)

### Library ###

.PHONY: library
library: library-$(DEFAULT_BUILD_TYPE)

.PHONY: static-library
static-library: static-library-$(DEFAULT_BUILD_TYPE)

.PHONY: shared-library
shared-library: shared-library-$(DEFAULT_BUILD_TYPE)

.PHONY: library-release
library-release: BUILD_TYPE = release
library-release: library-output-dirs $(LIBRARIES)

.PHONY: library-debug
library-debug: BUILD_TYPE = debug
library-debug: library-output-dirs $(LIBRARIES)

.PHONY: library-sanitize
library-sanitize: BUILD_TYPE = sanitize
library-sanitize: library-output-dirs $(LIBRARIES)

.PHONY: static-library-release
static-library-release: BUILD_TYPE = release
static-library-release: static-library-output-dirs $(STATIC_LIB)

.PHONY: static-library-debug
static-library-debug: BUILD_TYPE = debug
static-library-debug: static-library-output-dirs $(STATIC_LIB)

.PHONY: static-library-sanitize
static-library-sanitize: BUILD_TYPE = sanitize
static-library-sanitize: static-library-output-dirs $(STATIC_LIB)

.PHONY: shared-library-release
shared-library-release: BUILD_TYPE = release
shared-library-release: shared-library-output-dirs $(SHARED_LIB)

.PHONY: shared-library-debug
shared-library-debug: BUILD_TYPE = debug
shared-library-debug: shared-library-output-dirs $(SHARED_LIB)

.PHONY: shared-library-sanitize
shared-library-sanitize: BUILD_TYPE = sanitize
shared-library-sanitize: shared-library-output-dirs $(SHARED_LIB)

#### Library Build Rules #######################################################

$(STATIC_LIB): $(STATIC_OBJS)
	$(AR) crs $@ $^

$(SHARED_LIB): $(SHARED_OBJS)
	$(CC) -o $@ $^ -shared $(LDFLAGS)

$(INTERMEDIATE_DIR)/%.static.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) -o $@ $< -c -I$(HEADER_DIR) $(STATIC_LIB_FLAGS) \
		$(CFLAGS) $(LTOFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

$(INTERMEDIATE_DIR)/%.shared.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) -o $@ $< -c -I$(HEADER_DIR) $(SHARED_LIB_FLAGS) \
		$(CFLAGS) $(LTOFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

#### Directory Build Rules #####################################################

### General ###

.PHONY: output-dirs
output-dirs: library-output-dirs

%/:
	$(call MKDIR_P,"$@")

### Library ###

.PHONY: library-output-dirs
library-output-dirs: static-library-output-dirs shared-library-output-dirs

.PHONY: static-library-output-dirs
static-library-output-dirs: $(LIB_DIR)/ $(INTERMEDIATE_DIR)/

.PHONY: shared-library-output-dirs
shared-library-output-dirs: $(LIB_DIR)/ $(INTERMEDIATE_DIR)/

#### Linux Installation ########################################################

VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
VERSION_MAJOR = 0
VERSION_MINOR = 0
VERSION_PATCH = 0

DEST_DIR = # root

.PHONY: linux-install
linux-install:
	install -Dm755 "$(LIB_DIR)/lib$(NAME).so"       "$(DEST_DIR)/usr/lib/lib$(NAME).so.$(VERSION)"
	ln -snf        "lib$(NAME).so.$(VERSION)"       "$(DEST_DIR)/usr/lib/lib$(NAME).so.$(VERSION_MAJOR)"
	ln -snf        "lib$(NAME).so.$(VERSION_MAJOR)" "$(DEST_DIR)/usr/lib/lib$(NAME).so"
	
	find "$(HEADER_DIR)" -type f -exec install -Dm644 -t "$(DEST_DIR)/usr/include/$(NAME)/" "{}" \;
	
	install -Dm644 -t "$(DEST_DIR)/usr/lib/"                    "$(LIB_DIR)/lib$(NAME).a"
	install -Dm644 -t "$(DEST_DIR)/usr/share/licenses/$(NAME)/" "LICENSE"
	install -Dm644 -t "$(DEST_DIR)/usr/share/doc/$(NAME)/"      "README.md"
