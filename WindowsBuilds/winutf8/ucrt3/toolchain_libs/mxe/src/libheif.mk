# based on https://github.com/libvips/build-win64-mxe
PKG             := libheif
$(PKG)_WEBSITE  := http://www.libheif.org/
$(PKG)_DESCR    := libheif is a ISO/IEC 23008-12:2017 HEIF file format decoder and encoder.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.19.5
$(PKG)_CHECKSUM := d3cf0a76076115a070f9bc87cf5259b333a1f05806500045338798486d0afbaf
$(PKG)_GH_CONF  := strukturag/libheif/releases,v
$(PKG)_DEPS     := cc aom x265 jpeg libpng libde265

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DENABLE_PLUGIN_LOADING=0 \
        -DBUILD_TESTING=0 \
        -DWITH_EXAMPLES=0 \
        -DWITH_GDK_PIXBUF=0 \
        '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(subst -,/,$(INSTALL_STRIP_LIB))
endef
