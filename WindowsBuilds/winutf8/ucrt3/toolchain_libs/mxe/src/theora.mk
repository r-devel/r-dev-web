# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := theora
$(PKG)_WEBSITE  := https://theora.org/
$(PKG)_DESCR    := Theora
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.2.0
$(PKG)_CHECKSUM := 279327339903b544c28a92aeada7d0dcfd0397b59c2f368cc698ac56f515906e
$(PKG)_SUBDIR   := libtheora-$($(PKG)_VERSION)
$(PKG)_FILE     := libtheora-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://downloads.xiph.org/releases/theora/$($(PKG)_FILE)
$(PKG)_DEPS     := cc ogg vorbis

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.xiph.org/downloads/' | \
    $(SED) -n 's,.*libtheora-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # https://aur.archlinux.org/packages/mi/mingw-w64-libtheora/PKGBUILD
    $(SED) -i 's,EXPORTS,,' '$(1)/win32/xmingw32/libtheoradec-all.def'
    $(SED) -i 's,EXPORTS,,' '$(1)/win32/xmingw32/libtheoraenc-all.def'
    # re-generate to support aarch64, but only conditionally, as it doesn't
    # work on x86_64
    $(if $(findstring aarch64,$(TARGET)),\
        cd '$(1)' && rm aclocal.m4 && rm config.guess && cp ../../$(EXT_DIR)/config.guess ./ && \
            ./autogen.sh PKG_CONFIG='$(TARGET)-pkg-config' && \
            autoreconf -fiv -I m4 -I $(PREFIX)/$(TARGET)/share/aclocal \
    )
    cd '$(1)' && CONFIG_SHELL=$(SHELL) ./configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= doc_DATA=
endef
