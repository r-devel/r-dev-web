# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := minizip
$(PKG)_WEBSITE  := https://www.winimage.com/zLibDll/minizip.html
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.0.3
$(PKG)_CHECKSUM := 5f1dd0d38adbe9785cb9c4e6e47738c109d73a0afa86e58c4025ce3e2cc504ed
$(PKG)_GH_CONF  := zlib-ng/minizip-ng/releases
$(PKG)_DEPS     := cc bzip2 zlib openssl

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_TEST=OFF \
        -DUSE_ZLIB=ON
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -Wno-format \
        -DHAVE_STDINT_H -DHAVE_INTTYPES_H \
        '$(SOURCE_DIR)/minizip.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --libs-only-l`
endef
