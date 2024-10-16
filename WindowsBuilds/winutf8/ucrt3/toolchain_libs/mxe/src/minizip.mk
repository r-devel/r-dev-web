# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := minizip
$(PKG)_WEBSITE  := https://www.winimage.com/zLibDll/minizip.html
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.0.7
$(PKG)_CHECKSUM := a87f1f734f97095fe1ef0018217c149d53d0f78438bcb77af38adc21dff2dfbc
$(PKG)_GH_CONF  := zlib-ng/minizip-ng/releases
$(PKG)_DEPS     := cc bzip2 zlib openssl

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_TEST=OFF \
        -DUSE_ZLIB=ON
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's-\(/[^/;]\+\)\+/lib/lib\([[:alnum:]]\+\).a-\2-g' \
              -e '/INTERFACE_LINK_DIRECTORIES/d' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/$(PKG).cmake'

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -Wno-format \
        -DHAVE_STDINT_H -DHAVE_INTTYPES_H \
        '$(SOURCE_DIR)/minizip.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --libs-only-l`
endef
