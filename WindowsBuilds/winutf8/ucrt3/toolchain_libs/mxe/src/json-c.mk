# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := json-c
$(PKG)_WEBSITE  := https://github.com/json-c/json-c/wiki
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.18
$(PKG)_CHECKSUM := 602cdefc1d2aab8318fc0814b7ce7d59e72514d4276ca3eff92f35f86cf1c160
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION)-nodoc.tar.gz
$(PKG)_URL      := https://$(PKG)_releases.s3.amazonaws.com/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := cc
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://json-c_releases.s3.amazonaws.com' | \
    $(SED) -r 's,<Key>,\n<Key>,g' | \
    $(SED) -n 's,.*releases/json-c-\([0-9.]*\).tar.gz.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DDISABLE_WERROR=ON
#        CFLAGS=-Wno-error
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' install

    $(if $(BUILD_CROSS),
        '$(TARGET)-gcc' \
            -W -Wall -Werror -pedantic \
            '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-json-c.exe' \
            `'$(TARGET)-pkg-config' json-c --cflags --libs`
    )
endef

