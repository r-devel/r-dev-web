# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := coreutils
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 8.32
$(PKG)_CHECKSUM := 4458d8de7849df44ccab15e16b1548b285224dbba5f08fac070c1c0e0bcc4cfa
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://ftp.gnu.org/gnu/$(PKG)/$($(PKG)_FILE)
$(PKG)_URL_2    := https://ftpmirror.gnu.org/$(PKG)/$($(PKG)_FILE)
$(PKG)_WEBSITE  := https://www.gnu.org/software/coreutils
$(PKG)_OWNER    := https://github.com/tonytheodore
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

$(PKG)_DEPS_$(BUILD) := gettext gmp libiconv libtool

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ftp.gnu.org/gnu/coreutils/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="coreutils-\([0-9][^"]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

#define $(PKG)_BUILD_$(BUILD)
define $(PKG)_BUILD
     cd    '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_DISABLE_DOC_OPTS) \
        --host='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' man1_MANS=
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install man1_MANS=
endef
