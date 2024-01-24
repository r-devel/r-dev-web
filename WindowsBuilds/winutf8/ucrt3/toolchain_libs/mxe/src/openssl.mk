# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := openssl
$(PKG)_WEBSITE  := https://www.openssl.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.1.4
$(PKG)_CHECKSUM := 840af5366ab9b522bde525826be3ef0fb0af81c6a9ebd84caa600fea1731eee3
$(PKG)_SUBDIR   := openssl-$($(PKG)_VERSION)
$(PKG)_FILE     := openssl-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.openssl.org/source/$($(PKG)_FILE)
$(PKG)_URL_2    := https://www.openssl.org/source/old/$(call tr,$([a-z]),,$($(PKG)_VERSION))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc zlib
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.openssl.org/source/' | \
    $(SED) -n 's,.*openssl-\([0-9][0-9a-z.]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

$(PKG)_MAKE = $(MAKE) -C '$(1)' -j '$(JOBS)'\
        $(if $(BUILD_CROSS),\
          CROSS_COMPILE='$(TARGET)-' \
          CC='$(TARGET)-gcc' \
          RANLIB='$(TARGET)-ranlib' \
          AR='$(TARGET)-ar' \
          RC='$(TARGET)-windres' \
        ) \
        $(if $(BUILD_SHARED), ENGINESDIR='$(PREFIX)/$(TARGET)/bin/engines')

define $(PKG)_BUILD
    # remove previous install
    rm -rfv '$(PREFIX)/$(TARGET)/include/openssl'
    rm -rfv '$(PREFIX)/$(TARGET)/bin/engines'
    rm -fv '$(PREFIX)/$(TARGET)/'*/{libcrypto*,libssl*}
    rm -fv '$(PREFIX)/$(TARGET)/lib/pkgconfig/'{libcrypto*,libssl*,openssl*}

    cd '$(1)' && \
    $(if $(BUILD_CROSS),CC='$(TARGET)-gcc' RC='$(TARGET)-windres') ./Configure \
        @openssl-target@ \
        zlib \
        $(if $(BUILD_STATIC),no-module no-,)shared \
        no-capieng \
        --prefix='$(PREFIX)/$(TARGET)' \
        --libdir='$(PREFIX)/$(TARGET)/lib'
    $($(PKG)_MAKE) build_sw
    $($(PKG)_MAKE) install_sw
endef

$(PKG)_BUILD_i686-w64-mingw32   = $(subst @openssl-target@,mingw,$($(PKG)_BUILD))
$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @openssl-target@,mingw64,$($(PKG)_BUILD))
$(PKG)_BUILD_aarch64-w64-mingw32 = $(subst @openssl-target@,mingwarm64,$($(PKG)_BUILD))
$(PKG)_BUILD_x86_64-pc-linux-gnu = $(subst @openssl-target@,linux-x86_64,$($(PKG)_BUILD))

