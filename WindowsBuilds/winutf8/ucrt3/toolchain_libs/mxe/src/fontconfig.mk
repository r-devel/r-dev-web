# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := fontconfig
$(PKG)_WEBSITE  := https://fontconfig.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.17.1
$(PKG)_CHECKSUM := 9f5cae93f4fffc1fbc05ae99cdfc708cd60dfd6612ffc0512827025c026fa541
$(PKG)_SUBDIR   := fontconfig-$($(PKG)_VERSION)
$(PKG)_FILE     := fontconfig-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc expat freetype-bootstrap gettext

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://fontconfig.org/release/' | \
    $(SED) -n 's,.*fontconfig-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v '\([0-9]\+\.\)\{2\}9[0-9]' | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoreconf -fi
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-arch='$(TARGET)' \
        --with-expat='$(PREFIX)/$(TARGET)' \
        --disable-docs
    $(MAKE) -C '$(1)' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(MAKE) -C '$(1)' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=

    # fix pkg-config file
    $(SED) -i 's/^\(Libs.private:.*\)/\1 -lintl -liconv/g' \
      '$(PREFIX)/$(TARGET)/lib/pkgconfig/fontconfig.pc'
endef
