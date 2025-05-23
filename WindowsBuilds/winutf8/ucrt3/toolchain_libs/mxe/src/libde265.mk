PKG             := libde265
$(PKG)_WEBSITE  := https://www.libde265.org/
$(PKG)_DESCR    := libde265 is an open source implementation of the h.265 video codec.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.16
$(PKG)_CHECKSUM := b92beb6b53c346db9a8fae968d686ab706240099cdd5aff87777362d668b0de7
$(PKG)_GH_CONF  := strukturag/libde265/releases,v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
   cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DCMAKE_BUILD_TYPE="Release" \
        -DENABLE_DECODER=OFF

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # fix pkg-config file
    $(if $(BUILD_STATIC),\
        (echo 'Cflags.private: -DLIBDE265_STATIC_BUILD') >> \
          '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc')
endef
