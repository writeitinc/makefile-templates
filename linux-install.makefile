# This Makefile is based on a template.
# See: https://github.com/writeitinc/makefile-templates

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
