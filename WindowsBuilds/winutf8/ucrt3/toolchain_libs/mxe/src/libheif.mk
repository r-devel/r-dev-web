# based on https://github.com/libvips/build-win64-mxe
PKG             := libheif
$(PKG)_WEBSITE  := http://www.libheif.org/
$(PKG)_DESCR    := libheif is a ISO/IEC 23008-12:2017 HEIF file format decoder and encoder.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.20.2
$(PKG)_CHECKSUM := 68ac9084243004e0ef3633f184eeae85d615fe7e4444373a0a21cebccae9d12a
$(PKG)_GH_CONF  := strukturag/libheif/releases,v
$(PKG)_DEPS     := cc aom x265 jpeg libpng libde265

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DENABLE_PLUGIN_LOADING=0 \
        -DBUILD_TESTING=0 \
        -DWITH_EXAMPLES=0 \
        -DWITH_GDK_PIXBUF=0 \
        -DCMAKE_CXX_FLAGS="`$(TARGET)-pkg-config --cflags libde265`" \
        '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(subst -,/,$(INSTALL_STRIP_LIB))
endef
