# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := lerc
$(PKG)_WEBSITE  := https://github.com/esri/lerc
$(PKG)_DESCR    := Lerc
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.0.0
$(PKG)_CHECKSUM := 91431c2b16d0e3de6cbaea188603359f87caed08259a645fd5a3805784ee30a0
$(PKG)_GH_CONF  := esri/lerc/releases,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_URL      := https://github.com/esri/lerc/archive/v$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
            -DCMAKE_BUILD_TYPE="Release" \
         '$(1)' 
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    mv $(PREFIX)/$(TARGET)/lib/pkgconfig/Lerc.pc \
       $(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc

    echo "Libs.private: -lstdc++" >> \
       $(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc

    # Test
    '$(TARGET)-g++' \
        -W -Wall -pedantic \
        '$(SOURCE_DIR)/src/LercTest/main.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-lerc.exe' \
        `'$(TARGET)-pkg-config' lerc --cflags --libs`
endef
