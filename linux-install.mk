# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

DESTDIR = # root by default
PREFIX = /usr/local

.PHONY: linux-install
linux-install:
	install -Dm755 "$(LIB_DIR)/lib$(NAME).so"       "$(DESTDIR)$(PREFIX)/lib/lib$(NAME).so.$(VERSION)"
	ln -snf        "lib$(NAME).so.$(VERSION)"       "$(DESTDIR)$(PREFIX)/lib/lib$(NAME).so.$(VERSION_MAJOR)"
	ln -snf        "lib$(NAME).so.$(VERSION_MAJOR)" "$(DESTDIR)$(PREFIX)/lib/lib$(NAME).so"
	
	find "$(HEADER_DIR)" -type f -exec install -Dm644 "{}" "$(DESTDIR)$(PREFIX)/{}" \;
	
	install -Dm644 -t "$(DESTDIR)$(PREFIX)/lib/"                    "$(LIB_DIR)/lib$(NAME).a"
	install -Dm644 -t "$(DESTDIR)$(PREFIX)/share/licenses/$(NAME)/" "LICENSE"
	install -Dm644 -t "$(DESTDIR)$(PREFIX)/share/doc/$(NAME)/"      "README.md"
