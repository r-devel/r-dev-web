# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := flint
$(PKG)_WEBSITE  := https://www.flintlib.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.3.1
$(PKG)_CHECKSUM := 64d70e513076cfa971e0410b58c1da5d35112913e9a56b44e2c681b459d3eafb
$(PKG)_GH_CONF  := flintlib/flint/releases,v
$(PKG)_DEPS     := cc gmp mpfr pthreads

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && ./bootstrap.sh
    cd '$(SOURCE_DIR)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --enable-pthread \
        --with-gmp-include='$(PREFIX)/$(TARGET)/include' \
        --with-gmp-lib='$(PREFIX)/$(TARGET)/lib' \
        --with-mpfr-include='$(PREFIX)/$(TARGET)/include' \
        --with-mpfr-lib='$(PREFIX)/$(TARGET)/lib' \
        --without-blas \
        --without-gc \
        --without-ntl
    $(MAKE) -C '$(SOURCE_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(SOURCE_DIR)' -j 1 install $(MXE_DISABLE_CRUFT)

    '$(TARGET)-gcc' \
        -Wall -Werror -std=c99 -pedantic \
        '$(PWD)/src/$(PKG)-test.c' \
        -o \
        '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
