# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := intel-tbb
$(PKG)_WEBSITE  := https://www.threadingbuildingblocks.org
$(PKG)_DESCR    := Intel Threading Building Blocks
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2021.11.0
$(PKG)_CHECKSUM := 782ce0cab62df9ea125cdea253a50534862b563f1d85d4cda7ad4e77550ac363
$(PKG)_GH_CONF  := oneapi-src/oneTBB/releases/tag,v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DTBB_TEST=OFF \
        -DTBB_STRICT=OFF \
        $(if $(MXE_IS_LLVM),,-DCMAKE_C_FLAGS="-Wno-stringop-overflow")
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    mv '$(PREFIX)/$(TARGET)/lib/pkgconfig/tbb.pc' \
       '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # compile test
    '$(TARGET)-g++' -W -Wall \
        '$(SOURCE_DIR)/examples/test_all/fibonacci/fibonacci.cpp' \
        -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
