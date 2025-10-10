# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gdk-pixbuf
$(PKG)_WEBSITE  := https://gtk.org/
$(PKG)_DESCR    := GDK-pixbuf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.44.2
$(PKG)_CHECKSUM := ea4ed9930b10db0655fb24f7c35b3375a65c58afbc9d3eb7417a0fd112bb6b08
$(PKG)_SUBDIR   := gdk-pixbuf-$($(PKG)_VERSION)
$(PKG)_FILE     := gdk-pixbuf-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/gdk-pixbuf/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc meson-wrapper glib jasper jpeg libiconv libpng tiff

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/gdk-pixbuf/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\?\([0-9]\+\.[0-9.]\+\)<.*,\1,p" | \
    grep -v '^2\.9' | \
    head -1
endef

define $(PKG)_BUILD
    '$(MXE_MESON_WRAPPER)' $(MXE_MESON_OPTS) \
      -Dinstalled_tests=false \
      -Dintrospection=disabled \
      -Dman=false \
      $(if $(BUILD_STATIC),-Dbuiltin_loaders=all) \
    '$(BUILD_DIR)' '$(SOURCE_DIR)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)'
    '$(MXE_NINJA)' -C '$(BUILD_DIR)' -j '$(JOBS)' install
endef
