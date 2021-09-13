# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := proj
$(PKG)_WEBSITE  := https://trac.osgeo.org/proj/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 7.2.1
$(PKG)_CHECKSUM := b384f42e5fb9c6d01fe5fa4d31da2e91329668863a684f97be5d4760dbbf0a14
$(PKG)_SUBDIR   := proj-$($(PKG)_VERSION)
$(PKG)_FILE     := proj-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.osgeo.org/proj/$($(PKG)_FILE)
$(PKG)_DEPS     := cc sqlite curl tiff

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://proj4.org/download.html' | \
    $(SED) -n 's,.*proj-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        --with-curl='$(PREFIX)/$(TARGET)/bin/curl-config' \
        $(MXE_CONFIGURE_OPTS) \
        --with-mutex
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    # remove header which is not installed since 4.8.0
    rm -f '$(PREFIX)/$(TARGET)'/include/projects.h
    $(MAKE) -C '$(1)' -j 1 install
endef

