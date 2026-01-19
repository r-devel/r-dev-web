# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libdeflate
$(PKG)_WEBSITE  := https://github.com/ebiggers/libdeflate
$(PKG)_DESCR    := libdeflate
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.25
$(PKG)_CHECKSUM := d11473c1ad4c57d874695e8026865e38b47116bbcb872bfc622ec8f37a86017d
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

    # by error hdf5-static target contains -lfull_path_to_libz.a
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/$(PKG)-targets.cmake'

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/$(PKG)-targets-release.cmake'

endef
