# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libarchive
$(PKG)_WEBSITE  := https://www.libarchive.org/
$(PKG)_DESCR    := Libarchive
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.7.7
$(PKG)_CHECKSUM := 4cc540a3e9a1eebdefa1045d2e4184831100667e6d7d5b315bb1cbc951f8ddff
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.libarchive.org/downloads/$($(PKG)_FILE)
$(PKG)_DEPS     := cc bzip2 libiconv libxml2 nettle openssl xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.libarchive.org/downloads/' | \
    $(SED) -n 's,.*libarchive-\([0-9][^<]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    # use nettle instead of bcrypt for CNG(Crypto Next Generation)
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --disable-bsdtar \
        --disable-bsdcpio \
        --disable-bsdcat \
        --without-cng \
        --with-nettle \
        XML2_CONFIG='$(PREFIX)/$(TARGET)'/bin/xml2-config
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' man_MANS=
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install man_MANS=

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-libarchive.exe' \
        `'$(TARGET)-pkg-config' --libs-only-l --cflags libarchive`
endef
