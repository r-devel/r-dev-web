# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := cairo
$(PKG)_WEBSITE  := https://cairographics.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.18.0
$(PKG)_CHECKSUM := 243a0736b978a33dee29f9cca7521733b78a65b5418206fef7bd1c3d4cf10b64
$(PKG)_SUBDIR   := cairo-$($(PKG)_VERSION)
$(PKG)_FILE     := cairo-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://cairographics.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := cc fontconfig freetype-bootstrap glib libpng lzo pixman zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://cairographics.org/releases/?C=M;O=D' | \
    $(SED) -n 's,.*"cairo-\([0-9]\.[0-9][^"]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    '$(MXE_MESON_WRAPPER)' $(MXE_MESON_OPTS) \
      -Dxlib=disabled \
      -Dxcb=disabled \
      -Dgtk2-utils=disabled \
      -Dquartz=disabled \
      -Dsymbol-lookup=disabled \
      -Dspectre=disabled \
      -Dgtk_doc=false \
      -Dtests=disabled \
      -Dfontconfig=enabled \
      -Dfreetype=enabled \
      -Dzlib=enabled \
      -Dpng=enabled \
      '$(BUILD_DIR)' '$(SOURCE_DIR)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' install

    # fix pkg-config file
    $(if $(BUILD_STATIC),\
        (echo 'Cflags.private: -DCAIRO_WIN32_STATIC_BUILD';\
         echo 'Libs.private: $(if $(MXE_IS_LLVM),-lc++,-lstdc++)') >> \
          '$(PREFIX)/$(TARGET)/lib/pkgconfig/cairo.pc')
endef
