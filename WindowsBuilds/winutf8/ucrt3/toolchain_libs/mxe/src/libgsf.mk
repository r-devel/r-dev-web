# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgsf
$(PKG)_WEBSITE  := https://developer.gnome.org/gsf/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.14.51
$(PKG)_CHECKSUM := f0b83251f98b0fd5592b11895910cc0e19f798110b389aba7da1cb7c474017f5
$(PKG)_SUBDIR   := libgsf-$($(PKG)_VERSION)
$(PKG)_FILE     := libgsf-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/libgsf/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc bzip2 glib libxml2 zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/libgsf/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\?\([0-9]\+\.[0-9.]\+\)<.*,\1,p" | \
    head -1
endef

define $(PKG)_BUILD
    $(SED) -i 's,^\(Requires:.*\),\1 gio-2.0,' '$(1)'/libgsf-1.pc.in
    echo 'Libs.private: -lz -lbz2'          >> '$(1)'/libgsf-1.pc.in
    $(SED) -i 's,\ssed\s, $(SED) ,g'           '$(1)'/gsf/Makefile.in
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-nls \
        --disable-gtk-doc \
        --without-python \
        --with-zlib \
        --with-bz2 \
        --with-gio \
        $(shell [ `uname -s` == Darwin ] && echo "INTLTOOL_PERL=/usr/bin/perl") \
        PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config'
    $(MAKE) -C '$(1)'     -j '$(JOBS)' install-pkgconfigDATA
    $(MAKE) -C '$(1)/gsf' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
