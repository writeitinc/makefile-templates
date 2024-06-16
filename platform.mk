# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

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
