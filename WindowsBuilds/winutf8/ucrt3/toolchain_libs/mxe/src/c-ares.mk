PKG             := c-ares
$(PKG)_WEBSITE  := https://c-ares.org/
$(PKG)_DESCR    := c-ares is a C library for asynchronous DNS requests
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1_25_0
$(PKG)_CHECKSUM := 57549b266748ec22fa5706897c1e0f5a39b54b517362e3c774942bb2b7d15fb4
$(PKG)_GH_CONF  := c-ares/c-ares/tags,cares-
$(PKG)_SUBDIR   := $(PKG)-cares-$($(PKG)_VERSION)
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
