# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := intel-tbb
$(PKG)_WEBSITE  := https://www.threadingbuildingblocks.org
$(PKG)_DESCR    := Intel Threading Building Blocks
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2022.1.0
$(PKG)_CHECKSUM := ed067603ece0dc832d2881ba5c516625ac2522c665d95f767ef6304e34f961b5
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
