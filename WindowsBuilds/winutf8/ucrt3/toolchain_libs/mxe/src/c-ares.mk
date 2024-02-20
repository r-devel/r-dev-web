PKG             := c-ares
$(PKG)_WEBSITE  := https://c-ares.org/
$(PKG)_DESCR    := c-ares is a C library for asynchronous DNS requests
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1_26_0
$(PKG)_CHECKSUM := 4d1b2202f650633a4cad75ac06e63c462c01177cd2c5e8b2aa376213f126bde1
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
