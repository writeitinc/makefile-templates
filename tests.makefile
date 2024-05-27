# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

#### Build Config ##############################################################

# Flags #

TEST_CFLAGS = $(CFLAGS)
TEST_LDFLAGS = -L$(LIB_DIR) -l$(NAME) \
		  -Wl,-rpath,$(LIB_DIR) \
		  $(LDFLAGS)

# Inputs #

TEST_SOURCE_DIR = tests
TEST_HEADER_DIR = tests

TEST_SOURCES = $(wildcard $(TEST_SOURCE_DIR)/*.c)
TEST_HEADERS = $(wildcard $(TEST_HEADERS_DIR)/*.h)

# Outputs #

TEST_BIN_DIR = $(BIN_DIR)/tests
TESTS = $(patsubst $(TEST_SOURCE_DIR)/%.c, $(TEST_BIN_DIR)/%$(EXEC_EXT), $(TEST_SOURCES))

# Intermediates #

TEST_OBJS = $(patsubst $(TEST_SOURCE_DIR)/%.c, $(INTERMEDIATE_DIR)/%.test.o, $(TEST_SOURCES))
.SECONDARY: $(TEST_OBJS)

#### Build Targets #############################################################

release: $(TESTS)
debug: $(TESTS)
sanitize: $(TESTS)

.PHONY: tests
tests: tests-$(DEFAULT_BUILD_TYPE)

.PHONY: tests-release
tests-release: BUILD_TYPE = release
tests-release: test-output-dirs $(TESTS)

.PHONY: tests-debug
tests-debug: BUILD_TYPE = debug
tests-debug: test-output-dirs $(TESTS)

.PHONY: tests-sanitize
tests-sanitize: BUILD_TYPE = sanitize
tests-sanitize: test-output-dirs $(TESTS)

#### Build Rules ###############################################################

$(TEST_BIN_DIR)/%$(EXEC_EXT): $(INTERMEDIATE_DIR)/%.test.o $(LIBRARIES)
	$(CC) -o $@ $< \
		$(TEST_LDFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

$(INTERMEDIATE_DIR)/%.test.o: $(TEST_SOURCE_DIR)/%.c $(TEST_HEADERS) $(HEADERS)
	$(CC) -o $@ $< -c -I$(INCLUDE_DIR) \
		$(TEST_CFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

#### Directory Build Rules #####################################################

output-dirs: test-output-dirs

.PHONY: test-output-dirs
test-output-dirs: $(TEST_BIN_DIR)/ $(INTERMEDIATE_DIR)/
