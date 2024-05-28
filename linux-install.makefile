# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

PREFIX=/usr/local

.PHONY: linux-install
linux-install:
	install -Dm755 "$(LIB_DIR)/lib$(NAME).so"       "$(PREFIX)/lib/lib$(NAME).so.$(VERSION)"
	ln -snf        "lib$(NAME).so.$(VERSION)"       "$(PREFIX)/lib/lib$(NAME).so.$(VERSION_MAJOR)"
	ln -snf        "lib$(NAME).so.$(VERSION_MAJOR)" "$(PREFIX)/lib/lib$(NAME).so"
	
	find "$(HEADER_DIR)" -type f -exec install -Dm644 "{}" "$(PREFIX)/{}" \;
	
	install -Dm644 -t "$(PREFIX)/lib/"                    "$(LIB_DIR)/lib$(NAME).a"
	install -Dm644 -t "$(PREFIX)/share/licenses/$(NAME)/" "LICENSE"
	install -Dm644 -t "$(PREFIX)/share/doc/$(NAME)/"      "README.md"
