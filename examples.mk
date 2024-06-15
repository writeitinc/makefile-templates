# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

#### Build Config ##############################################################

# Flags #

EXAMPLE_CFLAGS = $(CFLAGS)
EXAMPLE_LDFLAGS = -L$(LIB_DIR) -l$(NAME) \
		  -Wl,-rpath,$(LIB_DIR) \
		  $(LDFLAGS)

# Inputs #

EXAMPLE_SOURCE_DIR = examples
EXAMPLE_HEADER_DIR = examples

EXAMPLE_SOURCES = $(wildcard $(EXAMPLE_SOURCE_DIR)/*.c)
EXAMPLE_HEADERS = $(wildcard $(EXAMPLE_HEADERS_DIR)/*.h)

# Outputs #

EXAMPLE_BIN_DIR = $(BIN_DIR)/examples
EXAMPLES = $(patsubst $(EXAMPLE_SOURCE_DIR)/%.c, $(EXAMPLE_BIN_DIR)/%$(EXEC_EXT), $(EXAMPLE_SOURCES))

# Intermediates #

EXAMPLE_OBJS = $(patsubst $(EXAMPLE_SOURCE_DIR)/%.c, $(INTERMEDIATE_DIR)/%.example.o, $(EXAMPLE_SOURCES))
.SECONDARY: $(EXAMPLE_OBJS)

#### Build Targets #############################################################

release: $(EXAMPLES)
debug: $(EXAMPLES)
sanitize: $(EXAMPLES)

.PHONY: examples
examples: examples-$(DEFAULT_BUILD_TYPE)

.PHONY: examples-release
examples-release: BUILD_TYPE = release
examples-release: example-output-dirs $(EXAMPLES)

.PHONY: examples-debug
examples-debug: BUILD_TYPE = debug
examples-debug: example-output-dirs $(EXAMPLES)

.PHONY: examples-sanitize
examples-sanitize: BUILD_TYPE = sanitize
examples-sanitize: example-output-dirs $(EXAMPLES)

#### Build Rules ###############################################################

$(EXAMPLE_BIN_DIR)/%$(EXEC_EXT): $(INTERMEDIATE_DIR)/%.example.o $(LIBRARIES)
	$(CC) -o $@ $< \
		$(EXAMPLE_LDFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

$(INTERMEDIATE_DIR)/%.example.o: $(EXAMPLE_SOURCE_DIR)/%.c $(EXAMPLE_HEADERS) $(HEADERS)
	$(CC) -o $@ $< -c -I$(INCLUDE_DIR) \
		$(EXAMPLE_CFLAGS) $(SANITIZE_FLAGS) $(DEFINES)

#### Directory Build Rules #####################################################

output-dirs: example-output-dirs

.PHONY: example-output-dirs
example-output-dirs: $(EXAMPLE_BIN_DIR)/ $(INTERMEDIATE_DIR)/
