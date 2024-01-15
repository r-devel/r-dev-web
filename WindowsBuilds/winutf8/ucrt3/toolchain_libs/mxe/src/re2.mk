PKG             := re2
$(PKG)_WEBSITE  := 2023-11-01
$(PKG)_DESCR    := Regular expression engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2023-11-01
$(PKG)_CHECKSUM := 4e6593ac3c71de1c0f322735bc8b0492a72f66ffccfad76e259fa21c41d27d8a
$(PKG)_GH_CONF  := google/re2/tags
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc abseil-cpp

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
            -DCMAKE_PREFIX_PATH='$(PREFIX)/$(TARGET)/lib/' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DRE2_BUILD_TESTING=OFF \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

endef
