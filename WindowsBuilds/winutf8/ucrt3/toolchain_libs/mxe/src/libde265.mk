PKG             := libde265
$(PKG)_WEBSITE  := https://www.libde265.org/
$(PKG)_DESCR    := libde265 is an open source implementation of the h.265 video codec.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.15
$(PKG)_CHECKSUM := 00251986c29d34d3af7117ed05874950c875dd9292d016be29d3b3762666511d
$(PKG)_GH_CONF  := strukturag/libde265/releases,v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
   cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DCMAKE_BUILD_TYPE="Release" \
        -DENABLE_DECODER=OFF

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
