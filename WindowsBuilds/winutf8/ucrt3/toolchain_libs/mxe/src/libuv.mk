# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libuv
$(PKG)_WEBSITE  := https://libuv.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.48.0
$(PKG)_CHECKSUM := 8c253adb0f800926a6cbd1c6576abae0bc8eb86a4f891049b72f9e5b7dc58f33
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
