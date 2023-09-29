PKG             := mingw-w64
$(PKG)_VERSION  := 11.0.1
$(PKG)_CHECKSUM := 3f66bce069ee8bed7439a1a13da7cb91a5e67ea6170f21317ac7f5794625ee10
$(PKG)_SUBDIR   := $(PKG)-v$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-v$($(PKG)_VERSION).tar.bz2
$(PKG)_PATCHES  := $(filter-out mingw-w64-access.patch, $($(PKG)_PATCHES))

PKG             := intel-tbb
$(PKG)_VERSION  := 2021.10.0
$(PKG)_CHECKSUM := 487023a955e5a3cc6d3a0d5f89179f9b6c0ae7222613a7185b0227ba0c83700b
$(PKG)_GH_CONF  := oneapi-src/oneTBB/releases/tag,v
$(PKG)_PATCHES  := $(filter-out intel-tbb-1-fixes.patch, $($(PKG)_PATCHES)) \
                   $(dir $(lastword $(MAKEFILE_LIST)))/intel-tbb-1-msys2-fixes.patch
define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DTBB_TEST=OFF \
        -DTBB_STRICT=OFF
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