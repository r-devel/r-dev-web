# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsndfile
$(PKG)_VERSION  := 1.2.2
$(PKG)_CHECKSUM := ffe12ef8add3eaca876f04087734e6e8e029350082f3251f565fa9da55b52121
$(PKG)_GH_CONF  := libsndfile/libsndfile/releases/latest,,,,,.tar.gz
$(PKG)_DEPS     := cc flac ogg vorbis opus

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
             -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
             -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
             -DCMAKE_BUILD_TYPE="Release" \
             -DBUILD_REGTEST=OFF \
             -DBUILD_PROGRAMS=OFF \
             -DBUILD_EXAMPLES=OFF \
             -DBUILD_TESTING=OFF \
             -DCMAKE_C_FLAGS='$(if $(BUILD_STATIC),-DFLAC__NO_DLL)' \
      '$(1)'
    
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
