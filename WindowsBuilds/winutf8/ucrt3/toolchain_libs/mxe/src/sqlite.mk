# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := sqlite
$(PKG)_WEBSITE  := https://www.sqlite.org/
$(PKG)_DESCR    := SQLite
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3490100
$(PKG)_CHECKSUM := 106642d8ccb36c5f7323b64e4152e9b719f7c0215acf5bfeac3d5e7f97b59254
$(PKG)_SUBDIR   := $(PKG)-autoconf-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.sqlite.org/2025/$($(PKG)_FILE)
$(PKG)_DEPS     := cc dlfcn-win32

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.sqlite.org/download.html' | \
    $(SED) -n 's,.*sqlite-autoconf-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        $(if $(BUILD_STATIC), \
          --enable-static --disable-shared, \
          --disable-static --enable-shared) \
        --disable-readline \
        --enable-threadsafe \
        --enable-load-extension \
        CFLAGS="-Os -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_RTREE=1"
    $(MAKE) -C '$(1)' -j 1 install
endef
