# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libxml2
$(PKG)_WEBSITE  := http://xmlsoft.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.12.10
$(PKG)_CHECKSUM := c3d8c0c34aa39098f66576fe51969db12a5100b956233dc56506f7a8679be995
$(PKG)_SUBDIR   := libxml2-$($(PKG)_VERSION)
$(PKG)_FILE     := libxml2-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/libxml2/2.12/$($(PKG)_FILE)
$(PKG)_URL_2    := https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/$($(PKG)_FILE)
$(PKG)_DEPS     := cc xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/libxml2/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\([0-9,\.]\+\)<.*,\\1,p" | \
    $(SORT) -Vr | head -1
endef

define $(PKG)_BUILD
    $(SED) -i 's,`uname`,MinGW,g' '$(1)/xml2-config.in'
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-zlib='$(PREFIX)/$(TARGET)' \
        --without-debug \
        --without-python \
        --without-threads \
        --with-http
    $(MAKE) -C '$(1)' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(MAKE) -C '$(1)' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    ln -sf '$(PREFIX)/$(TARGET)/bin/xml2-config' '$(PREFIX)/bin/$(TARGET)-xml2-config'
endef
