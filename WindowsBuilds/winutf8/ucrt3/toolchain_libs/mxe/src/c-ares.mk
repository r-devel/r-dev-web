PKG             := c-ares
$(PKG)_WEBSITE  := https://c-ares.org/
$(PKG)_DESCR    := c-ares is a C library for asynchronous DNS requests
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.34.6
$(PKG)_CHECKSUM := 912dd7cc3b3e8a79c52fd7fb9c0f4ecf0aaa73e45efda880266a2d6e26b84ef5
$(PKG)_GH_CONF  := c-ares/c-ares/releases/tag,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DCARES_STATIC=$(CMAKE_STATIC_BOOL) \
            -DCARES_SHARED=$(CMAKE_SHARED_BOOL) \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

endef
