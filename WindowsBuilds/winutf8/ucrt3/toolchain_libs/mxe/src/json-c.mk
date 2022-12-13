# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := json-c
$(PKG)_WEBSITE  := https://github.com/json-c/json-c/wiki
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.16
$(PKG)_CHECKSUM := ac8a3dd6820daaca579b23fbc74664310fbc3d67f52f6707cda67d21dde5570f
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION)-nodoc.tar.gz
$(PKG)_URL      := https://$(PKG)_releases.s3.amazonaws.com/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://json-c_releases.s3.amazonaws.com' | \
    $(SED) -r 's,<Key>,\n<Key>,g' | \
    $(SED) -n 's,.*releases/json-c-\([0-9.]*\).tar.gz.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DDISABLE_WERROR=ON
#        CFLAGS=-Wno-error
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' install

    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-json-c.exe' \
        `'$(TARGET)-pkg-config' json-c --cflags --libs`
endef

