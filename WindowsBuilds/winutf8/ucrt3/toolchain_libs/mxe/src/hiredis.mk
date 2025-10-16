# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := hiredis
$(PKG)_WEBSITE  := https://github.com/redis/hiredis
$(PKG)_DESCR    := HIREDIS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.3.0
$(PKG)_CHECKSUM := 25cee4500f359cf5cad3b51ed62059aadfc0939b05150c1f19c7e2829123631c
$(PKG)_GH_CONF  := redis/hiredis/releases,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_URL      := https://github.com/redis/hiredis/archive/v$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc openssl

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
            -DENABLE_SSL=ON \
            -DCMAKE_BUILD_TYPE="Release" \
            -DENABLE_EXAMPLES=OFF \
            -DDISABLE_TESTS=ON \
            -DCMAKE_C_FLAGS="-Wno-int-conversion" \
         '$(1)' 
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/share/$(PKG)/$(PKG)-targets-release.cmake' \
                 '$(PREFIX)/$(TARGET)/share/$(PKG)_ssl/$(PKG)_ssl-targets-release.cmake'

    # Test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic \
        $(if $(MXE_IS_LLVM),"-Wno-sometimes-uninitialized") \
        '$(SOURCE_DIR)/test.c' -o '$(PREFIX)/$(TARGET)/bin/test-hiredis.exe' \
        `'$(TARGET)-pkg-config' hiredis --cflags --libs`
endef
