LIB_NAME     := greeter
LANGUAGE     := d
LANGUAGE_CAP := D

SRC_DIR   := source
BUILD_DIR := build
OBJ_DIR   := $(BUILD_DIR)/obj
DI_DIR    := $(BUILD_DIR)/di

TARGET_TRIPLE := $(shell gcc -dumpmachine)

DESTDIR     := /fakeusr
PREFIX      := usr/local
LIB_DIR     := $(PREFIX)/lib
INCLUDE_DIR := $(PREFIX)/include

DC      := dmd
DCFLAGS := -O -release -fPIC -I$(SRC_DIR) -defaultlib=phobos2

VERSION_MAJOR := 1
VERSION_MINOR := 0
VERSION_PATCH := 0
VERSION       := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

SRCS := $(shell find $(SRC_DIR) -name '*.d')
OBJS := $(patsubst $(SRC_DIR)/%.d,$(OBJ_DIR)/%.o,$(SRCS))
DIS  := $(patsubst $(SRC_DIR)/%.d,$(DI_DIR)/%.di,$(SRCS))

INTERFACE_DIR     := $(DI_DIR)/$(LIB_NAME)
STATIC_LIB        := lib$(LIB_NAME)-$(LANGUAGE).a
SHARED_LIB        := lib$(LIB_NAME)-$(LANGUAGE).so
SHARED_LIB_FULL   := lib$(LIB_NAME)-$(LANGUAGE).so.$(VERSION)
SHARED_LIB_SONAME := lib$(LIB_NAME)-$(LANGUAGE).so.$(VERSION_MAJOR)

.PHONY: all clean install uninstall

$(LIB_NAME)-$(LANGUAGE): 
	@$(MAKE) --no-print-directory d-interface d-static-lib d-shared-lib

d-interface: $(DIS)
d-static-lib: $(STATIC_LIB)
d-shared-lib: $(SHARED_LIB)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.d 
	@mkdir -p $(dir $@)
	$(DC) $(DCFLAGS) -c $< -of$@

$(DI_DIR)/%.di: $(SRC_DIR)/%.d
	@mkdir -p $(dir $@)
	$(DC) $(DCFLAGS) -H -Hf$@ -c $< -of/dev/null

$(STATIC_LIB): $(OBJS)
	ar rcs $@ $^

$(SHARED_LIB_FULL): $(OBJS)
	$(DC) $(DCFLAGS) -shared -of$@ $^ -L-soname=$(SHARED_LIB_SONAME)

$(SHARED_LIB): $(SHARED_LIB_FULL)
	ln -sf $(SHARED_LIB_FULL) $(SHARED_LIB)
	ln -sf $(SHARED_LIB_FULL) $(SHARED_LIB_SONAME)

clean:
	rm -rf $(BUILD_DIR) $(STATIC_LIB) $(SHARED_LIB) $(SHARED_LIB_FULL) $(SHARED_LIB_SONAME)

install: $(LIB_NAME)-$(LANGUAGE)
	install -d $(DESTDIR)/$(INCLUDE_DIR)/$(LANGUAGE)
	cp -r $(INTERFACE_DIR) $(DESTDIR)/$(INCLUDE_DIR)/$(LANGUAGE)
	install -d $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)
	install -m 644 $(STATIC_LIB) $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)
	install -m 755 $(SHARED_LIB_FULL) $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)
	ln -sf $(SHARED_LIB_FULL) $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(SHARED_LIB_SONAME)
	ln -sf $(SHARED_LIB_FULL) $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(SHARED_LIB)

uninstall:
	rm -f $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(STATIC_LIB)
	rm -f $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(SHARED_LIB)
	rm -f $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(SHARED_LIB_SONAME)
	rm -f $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE)/$(SHARED_LIB_FULL)
	rm -rf $(DESTDIR)/$(INCLUDE_DIR)/$(LANGUAGE)/$(LIB_NAME)
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/$(INCLUDE_DIR)/$(LANGUAGE) || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/$(LIB_DIR)/$(TARGET_TRIPLE) || true

format:
	dub run dfmt -- $(shell find $(SRC_DIR) -name '*.d')
