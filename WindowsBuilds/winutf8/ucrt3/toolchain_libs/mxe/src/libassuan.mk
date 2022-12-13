# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libassuan
$(PKG)_WEBSITE  := https://www.gnupg.org/related_software/libassuan/
$(PKG)_DESCR    := libassuan
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.5.5
$(PKG)_CHECKSUM := 8e8c2fcc982f9ca67dcbb1d95e2dc746b1739a4668bc20b3a3c5be632edb34e4
$(PKG)_SUBDIR   := libassuan-$($(PKG)_VERSION)
$(PKG)_FILE     := libassuan-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://gnupg.org/ftp/gcrypt/libassuan/$($(PKG)_FILE)
$(PKG)_URL_2    := https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libassuan/$($(PKG)_FILE)
$(PKG)_DEPS     := cc gettext libgpg_error

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gnupg.org/ftp/gcrypt/libassuan/' | \
    $(SED) -n 's,.*libassuan-\([1-9]\.[1-9]\.[0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && GPG_ERROR_CONFIG=$(PREFIX)/bin/$(TARGET)-gpg-error-config ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-nls \
        --disable-languages
    $(MAKE) -C '$(1)/src' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(MAKE) -C '$(1)/src' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    ln -sf '$(PREFIX)/$(TARGET)/bin/libassuan-config' '$(PREFIX)/bin/$(TARGET)-libassuan-config'
endef
