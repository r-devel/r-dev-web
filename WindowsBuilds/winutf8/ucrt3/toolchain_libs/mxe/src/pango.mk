# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := pango
$(PKG)_WEBSITE  := https://www.pango.org/
$(PKG)_DESCR    := Pango
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.56.3
$(PKG)_CHECKSUM := 2606252bc25cd8d24e1b7f7e92c3a272b37acd6734347b73b47a482834ba2491
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
        -Dfreetype=enabled \
        -Dfontconfig=enabled \
        '$(BUILD_DIR)' '$(SOURCE_DIR)' && \
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' && \
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' install

    # fix pkg-config file
    $(SED) -i 's!^\(Libs:.*\)!\1 $(if $(MXE_IS_LLVM),-lc++,-lstdc++)!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG)win32.pc'
endef
