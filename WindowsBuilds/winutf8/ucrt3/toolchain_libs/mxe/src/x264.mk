# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := x264
$(PKG)_WEBSITE  := https://www.videolan.org/developers/x264.html
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 373697b4
$(PKG)_CHECKSUM := f4e6a1f093323597b5c05ce2a7d8b7a1a561f1e9f7342dc3af8b0060f54cc34a
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://code.videolan.org/videolan/x264/-/archive/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc liblsmash \
                   $(if $(findstring x86_64, $(TARGET)), $(BUILD)~nasm, \
                       $(if $(findstring i686, $(TARGET)), $(BUILD)~nasm ))

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://git.videolan.org/?p=x264.git;a=shortlog' | \
    $(SED) -n 's,.*\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\).*,\1\2\3-2245,p' | \
    $(SORT) | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && AS='$(PREFIX)/$(BUILD)/bin/nasm' '$(SOURCE_DIR)/configure'\
        $(MXE_CONFIGURE_OPTS) \
        --cross-prefix='$(TARGET)'- \
        --enable-win32thread \
        --disable-lavf \
        $(if $(findstring aarch64,$(TARGET)),--disable-asm) \
        --disable-swscale   # Avoid circular dependency with ffmpeg. Remove if undesired.
    $(MAKE) -C '$(BUILD_DIR)' -j 1 uninstall
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
