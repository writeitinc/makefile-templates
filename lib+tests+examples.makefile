# This Makefile is based on a template (lib+tests+examples.makefile version 1.0.0).
# See: https://github.com/writeitinc/makefile-templates

NAME = # give it a name!
SOURCE_DIR = $(WORKING_DIR)/src
TEST_DIR = $(WORKING_DIR)/tests
EXAMPLE_DIR = $(WORKING_DIR)/examples

ifndef NAME
$(error NAME is not set)
endif

CFLAGS = $(WFLAGS) $(OPTIM) $(IFLAGS)

CSTD = c99
WFLAGS = -Wall -Wextra -pedantic -std=$(CSTD)
IFLAGS = -I$(INCLUDE_DIR)

WORKING_DIR = .
BUILD_DIR = build

INCLUDE_DIR = $(BUILD_DIR)/include
HEADER_DIR = $(INCLUDE_DIR)/$(NAME)

OBJ_DIR = $(BUILD_DIR)/obj
STATIC_OBJ_DIR = $(OBJ_DIR)/static
SHARED_OBJ_DIR = $(OBJ_DIR)/shared
TEST_OBJ_DIR = $(OBJ_DIR)/tests
EXAMPLE_OBJ_DIR = $(OBJ_DIR)/examples

LIB_DIR = $(BUILD_DIR)/lib
BIN_DIR = $(BUILD_DIR)/bin

LIBRARIES = $(STATIC_LIB) $(SHARED_LIB)
STATIC_LIB = $(LIB_DIR)/lib$(NAME).a
SHARED_LIB = $(LIB_DIR)/lib$(NAME).so

BINARIES = # $(BIN_DIR)/some-test $(BIN_DIR)/some-example

.PHONY: default
default: release

.PHONY: release
release: OPTIM = -O3 $(LTOFLAGS)
release: dirs headers $(LIBRARIES) $(BINARIES)

.PHONY: debug
debug: DEBUG = -fsanitize=address,undefined
debug: OPTIM = -g
debug: dirs headers $(LIBRARIES) $(BINARIES)

# library

SOURCES = $(wildcard $(SOURCE_DIR)/*.c)
HEADERS = $(wildcard $(SOURCE_DIR)/*.h)
STATIC_OBJS = $(patsubst $(SOURCE_DIR)/%.c, $(STATIC_OBJ_DIR)/%.o, $(SOURCES))
SHARED_OBJS = $(patsubst $(SOURCE_DIR)/%.c, $(SHARED_OBJ_DIR)/%.o, $(SOURCES))

PIC_FLAGS = -fPIC

$(STATIC_LIB): $(STATIC_OBJS)
	$(AR) crs $@ $^

$(SHARED_LIB): $(SHARED_OBJS)
	$(CC) -o $@ $^ -shared $(PIC_FLAGS) $(LDFLAGS)

$(STATIC_OBJ_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) -o $@ $< -c $(CFLAGS) $(DEBUG) $(DEFINES)

$(SHARED_OBJ_DIR)/%.o: $(SOURCE_DIR)/%.c $(HEADERS)
	$(CC) -o $@ $< -c $(PIC_FLAGS) $(CFLAGS) $(DEBUG) $(DEFINES)

# headers

.PHONY: headers
headers: $(HEADER_DIR)

$(HEADER_DIR): $(HEADERS)
	mkdir -p $@
	cp -u -t $@/ $^
	touch $@

# tests

TEST_HEADERS = $(wildcard $(TEST_DIR)/*.h)

TEST_LDFLAGS = -L$(LIB_DIR) -l:lib$(NAME).a $(LDFLAGS)

$(BIN_DIR)/%: $(TEST_OBJ_DIR)/%.o $(LIBRARIES)
	$(CC) -o $@ $< $(TEST_LDFLAGS) $(DEBUG) $(DEFINES)

$(TEST_OBJ_DIR)/%.o: $(TEST_DIR)/%.c $(HEADERS) $(TEST_HEADERS)
	$(CC) -o $@ $< -c $(CFLAGS) $(DEBUG) $(DEFINES)

# examples

EXAMPLE_HEADERS = $(wildcard $(EXAMPLE_DIR)/*.h)

EXAMPLE_LDFLAGS = -L$(LIB_DIR) -l:lib$(NAME).a $(LDFLAGS)

$(BIN_DIR)/%: $(EXAMPLE_OBJ_DIR)/%.o $(LIBRARIES)
	$(CC) -o $@ $< $(EXAMPLE_LDFLAGS) $(DEBUG) $(DEFINES)

$(EXAMPLE_OBJ_DIR)/%.o: $(EXAMPLE_DIR)/%.c $(HEADERS) $(EXAMPLE_HEADERS)
	$(CC) -o $@ $< -c $(CFLAGS) $(DEBUG) $(DEFINES)

# dirs

.PHONY: dirs
dirs: $(INCLUDE_DIR)/ $(STATIC_OBJ_DIR)/ $(SHARED_OBJ_DIR)/ $(TEST_OBJ_DIR)/ $(EXAMPLE_OBJ_DIR)/ $(LIB_DIR)/ $(BIN_DIR)/

%/:
	mkdir -p $@

# install

VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
VERSION_MAJOR = 0
VERSION_MINOR = 0
VERSION_PATCH = 0

DEST_DIR = # root

.PHONY: install-linux
install-linux:
	install -Dm755 "build/lib/lib$(NAME).so"        "$(DEST_DIR)/usr/lib/lib$(NAME).so.$(VERSION)"
	ln -snf        "lib$(NAME).so.$(VERSION)"       "$(DEST_DIR)/usr/lib/lib$(NAME).so.$(VERSION_MAJOR)"
	ln -snf        "lib$(NAME).so.$(VERSION_MAJOR)" "$(DEST_DIR)/usr/lib/lib$(NAME).so"
	
	install -Dm644 -t "$(DEST_DIR)/usr/lib/"                    "build/lib/lib$(NAME).a"
	install -Dm644 -t "$(DEST_DIR)/usr/include/$(NAME)/"        "build/include/$(NAME)/$(NAME).h"
	install -Dm644 -t "$(DEST_DIR)/usr/share/licenses/$(NAME)/" "LICENSE"
	install -Dm644 -t "$(DEST_DIR)/usr/share/doc/$(NAME)/"      "README.md"

# clean

.PHONY: clean
clean:
	$(RM) -r build/*
