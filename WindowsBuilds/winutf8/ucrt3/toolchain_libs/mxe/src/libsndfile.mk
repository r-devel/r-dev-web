# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsndfile
$(PKG)_VERSION  := 1.2.0
$(PKG)_CHECKSUM := 0e30e7072f83dc84863e2e55f299175c7e04a5902ae79cfb99d4249ee8f6d60a
$(PKG)_GH_CONF  := libsndfile/libsndfile/releases/latest,,,,,.tar.xz
$(PKG)_DEPS     := cc flac ogg vorbis opus

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && autoreconf -fi
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --disable-sqlite \
        --enable-external-libs \
        --disable-octave \
        --disable-alsa \
        --disable-shave \
        PKG_CONFIG='$(TARGET)-pkg-config' \
        CFLAGS=$(if $(BUILD_STATIC),'-DFLAC__NO_DLL')
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install $(MXE_DISABLE_CRUFT)
endef
