PKG             := abseil-cpp
$(PKG)_WEBSITE  := https://abseil.io
$(PKG)_DESCR    := Abseil
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 20240722.0
$(PKG)_CHECKSUM := f50e5ac311a81382da7fa75b97310e4b9006474f9560ac46f54a9967f07d4ae3
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

    # fix pkg-config files
    # remove -Wnon-virtual-dtor, which is somewhat controversial (sometimes
    # it is ok to have a non-virtual destructor in a base class, even abseil
    # itself disables the warning for some classes - but then, other
    # software may be built together with abseil which doesn't expect it
    # should be disabling the warning)
    $(SED) -i -e 's/-Wnon-virtual-dtor//g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/absl_'*.pc
endef
