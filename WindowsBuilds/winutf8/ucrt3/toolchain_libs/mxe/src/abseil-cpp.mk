PKG             := abseil-cpp
$(PKG)_WEBSITE  := https://abseil.io
$(PKG)_DESCR    := Abseil
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 20240116.1
$(PKG)_CHECKSUM := 3c743204df78366ad2eaf236d6631d83f6bc928d1705dd0000b872e53b73dc6a
$(PKG)_GH_CONF  := abseil/abseil-cpp/tags
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_DEPS     := cc
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS_$(BUILD) :=

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DABSL_PROPAGATE_CXX_STD=ON \
            -DCMAKE_CXX_STANDARD=17 \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
