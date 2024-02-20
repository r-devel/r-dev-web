# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := pango
$(PKG)_WEBSITE  := https://www.pango.org/
$(PKG)_DESCR    := Pango
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.51.2
$(PKG)_CHECKSUM := 3dba407f2b5fc117e192f3025f0a1cc8edc1fd9b934b1c578b2b97342139415a
$(PKG)_SUBDIR   := pango-$($(PKG)_VERSION)
$(PKG)_FILE     := pango-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/pango/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc meson-wrapper cairo fontconfig freetype glib harfbuzz fribidi

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/pango/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\?\([0-9]\+\.[0-9.]\+\)<.*,\1,p" | \
    head -1
endef

define $(PKG)_BUILD
    '$(MXE_MESON_WRAPPER)' $(MXE_MESON_OPTS) \
        --auto-features=enabled \
        -Dlibthai=disabled \
        -Dxft=disabled \
        -Dintrospection=disabled \
        '$(BUILD_DIR)' '$(SOURCE_DIR)' && \
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' && \
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' install

    # fix pkg-config file
    $(SED) -i 's!^\(Libs:.*\)!\1 $(if $(MXE_IS_LLVM),-lc++,-lstdc++)!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG)win32.pc'
endef
