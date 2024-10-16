# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libdeflate
$(PKG)_WEBSITE  := https://github.com/ebiggers/libdeflate
$(PKG)_DESCR    := libdeflate
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.22
$(PKG)_CHECKSUM := 7f343c7bf2ba46e774d8a632bf073235e1fd27723ef0a12a90f8947b7fe851d6
$(PKG)_GH_CONF  := ebiggers/libdeflate/releases,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_URL      := https://github.com/ebiggers/libdeflate/archive/v$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DLIBDEFLATE_BUILD_SHARED_LIB=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
            -DLIBDEFLATE_BUILD_GZIP=OFF \
            -DCMAKE_BUILD_TYPE="Release" \
         '$(1)' 
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
