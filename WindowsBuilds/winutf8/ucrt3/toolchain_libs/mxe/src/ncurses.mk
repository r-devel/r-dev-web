# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ncurses
$(PKG)_WEBSITE  := https://www.gnu.org/software/ncurses/
$(PKG)_DESCR    := Ncurses
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.2
$(PKG)_SUBDIR   := ncurses-$($(PKG)_VERSION)
$(PKG)_FILE     := ncurses-$($(PKG)_VERSION).tar.gz
$(PKG)_CHECKSUM := 30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d
$(PKG)_URL      := https://ftp.gnu.org/gnu/ncurses/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc libgnurx $(BUILD)~$(PKG)

$(PKG)_DEPS_$(BUILD) :=

define $(PKG)_UPDATE_RELEASE
    $(WGET) -q -O- 'https://ftp.gnu.org/gnu/ncurses/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="ncurses-\([0-9][^"]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && \
        TIC_PATH='$(PREFIX)/$(BUILD)/bin/tic' \
        $(SOURCE_DIR)/configure \
        --host='$(TARGET)' \
        --build="`config.guess`" \
        --prefix=$(PREFIX)/$(TARGET) \
        --with-build-cc=$(BUILD_CC) \
        --with-build-cpp='$(BUILD_CC) -E' \
        --disable-home-terminfo \
        --enable-sp-funcs \
        --enable-term-driver \
        --enable-interop \
        --without-debug \
        --without-ada \
        --without-manpages \
        --without-progs \
        --without-tests \
        --enable-pc-files \
        --with-pkg-config-libdir='$(PREFIX)/$(TARGET)/lib/pkgconfig' \
        $(if $(BUILD_STATIC), \
            --with-normal    --without-shared --with-static, \
            --without-normal --without-static --with-shared) \
        CFLAGS='-std=gnu99'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef

define $(PKG)_BUILD_$(BUILD)
    # native build of terminfo compiler
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        --prefix=$(PREFIX)/$(TARGET) \
        --with-normal \
        --without-shared \
        --with-static \
        CFLAGS='-std=gnu99'
    $(MAKE) -C '$(BUILD_DIR)/include' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)/progs'   -j '$(JOBS)' tic
    $(INSTALL) -m755 '$(BUILD_DIR)/progs/tic' '$(PREFIX)/$(TARGET)/bin'
endef
