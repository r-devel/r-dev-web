# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := cfitsio
$(PKG)_WEBSITE  := https://heasarc.gsfc.nasa.gov/fitsio/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3450
$(PKG)_CHECKSUM := bf6012dbe668ecb22c399c4b7b2814557ee282c74a7d5dc704eb17c30d9fb92e
$(PKG)_SUBDIR   := cfitsio
$(PKG)_FILE     := cfitsio$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/$($(PKG)_FILE)
$(PKG)_DEPS     := cc curl

define $(PKG)_UPDATE
    $(WGET) -q -O- "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/?C=M;O=D" | \
    grep -i '<a href="cfitsio.*tar' | \
    $(SED) -n 's,.*cfitsio\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && LDFLAGS="`'$(TARGET)-pkg-config' --libs-only-l libcurl`" \
        $(TARGET)-cmake --trace-expand '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DCMAKE_C_FLAGS='$(if $(BUILD_STATIC),-DCURL_STATICLIB,)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # create pkg-config files
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: A FITS File Subroutine Library'; \
     echo 'Requires: libcurl'; \
     echo 'Libs: -l$(PKG)';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-cfitsio.exe' \
        `'$(TARGET)-pkg-config' cfitsio --cflags --libs`
endef

$(PKG)_BUILD_SHARED =
