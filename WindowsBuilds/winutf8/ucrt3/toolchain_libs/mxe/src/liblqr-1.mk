# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := liblqr-1
$(PKG)_WEBSITE  := https://liblqr.wikidot.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.4.3
$(PKG)_CHECKSUM := 862fc5cecaa96d38d4d9279c8a6fbfc276393f0548909ee0912e41df59894471
$(PKG)_SUBDIR   := liblqr-1-$($(PKG)_VERSION)
$(PKG)_FILE     := liblqr-1-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://liblqr.wdfiles.com/local--files/en:download-page/$($(PKG)_FILE)
$(PKG)_DEPS     := cc glib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://liblqr.wikidot.com/en:download-page' | \
    $(SED) -n 's,.*liblqr-1-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoconf && ./configure \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-shared \
        --enable-static \
        --disable-declspec \
        --disable-install-man
    $(MAKE) -C '$(1)' -j
    $(MAKE) -C '$(1)' -j 1 install
endef

$(PKG)_BUILD_SHARED =
