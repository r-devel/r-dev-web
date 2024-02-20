# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := pixman
$(PKG)_WEBSITE  := https://cairographics.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.43.2
$(PKG)_CHECKSUM := ea79297e5418fb528d0466e8b5b91d1be88857fa3706f49777b2925a72ae9924
$(PKG)_SUBDIR   := pixman-$($(PKG)_VERSION)
$(PKG)_FILE     := pixman-$($(PKG)_VERSION).tar.gz
#$(PKG)_URL      := https://cairographics.org/snapshots/$($(PKG)_FILE)
$(PKG)_URL      := https://xorg.freedesktop.org/archive/individual/lib/$($(PKG)_FILE)
$(PKG)_DEPS     := cc meson-wrapper libpng

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://xorg.freedesktop.org/archive/individual/lib/?C=M;O=D' | \
    $(SED) -n 's,.*"pixman-\([0-9][^"]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    '$(MXE_MESON_WRAPPER)' $(MXE_MESON_OPTS) \
      $(if $(MXE_IS_LLVM),-Da64-neon=disabled) \
      -Dtests=disabled \
      -Ddemos=disabled \
      -Dgtk=disabled \
      '$(BUILD_DIR)' '$(SOURCE_DIR)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' install
endef
