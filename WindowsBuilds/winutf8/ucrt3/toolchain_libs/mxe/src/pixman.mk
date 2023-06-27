# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := pixman
$(PKG)_WEBSITE  := https://cairographics.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.42.2
$(PKG)_CHECKSUM := ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e
$(PKG)_SUBDIR   := pixman-$($(PKG)_VERSION)
$(PKG)_FILE     := pixman-$($(PKG)_VERSION).tar.gz
#$(PKG)_URL      := https://cairographics.org/snapshots/$($(PKG)_FILE)
$(PKG)_URL      := https://xorg.freedesktop.org/archive/individual/lib/$($(PKG)_FILE)
$(PKG)_DEPS     := cc libpng

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://xorg.freedesktop.org/archive/individual/lib/?C=M;O=D' | \
    $(SED) -n 's,.*"pixman-\([0-9][^"]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(if $(MXE_IS_LLVM),--disable-arm-a64-neon) \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef
