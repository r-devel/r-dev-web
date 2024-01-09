# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libuv
$(PKG)_WEBSITE  := https://libuv.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.47.0
$(PKG)_CHECKSUM := d50af7e6d72526db137e66fad812421c8a1cae09d146b0ec2bb9a22c5f23ba93
$(PKG)_GH_CONF  := libuv/libuv/tags, v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && sh autogen.sh
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --libs`
endef
