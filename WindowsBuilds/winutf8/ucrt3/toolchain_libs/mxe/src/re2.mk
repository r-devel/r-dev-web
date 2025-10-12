PKG             := re2
$(PKG)_WEBSITE  := https://github.com/google/re2/
$(PKG)_DESCR    := Regular expression engine
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2025-08-12
$(PKG)_CHECKSUM := 2f3bec634c3e51ea1faf0d441e0a8718b73ef758d7020175ed7e352df3f6ae12
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
