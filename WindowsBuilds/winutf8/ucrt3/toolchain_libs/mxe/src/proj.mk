# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := proj
$(PKG)_WEBSITE  := https://trac.osgeo.org/proj/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 9.3.0
$(PKG)_CHECKSUM := 91a3695a004ea28db0448a34460bed4cc3b130e5c7d74339ec999efdab0e547d
$(PKG)_SUBDIR   := proj-$($(PKG)_VERSION)
$(PKG)_FILE     := proj-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.osgeo.org/proj/$($(PKG)_FILE)
$(PKG)_DEPS     := cc sqlite curl tiff

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://download.osgeo.org/proj/' | \
    $(SED) -n 's,.*title="proj-\([0-9.]\+\)\.tar\.gz".*,\1,p' | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DBUILD_APPS=OFF \
        -DCMAKE_CXX_FLAGS='$(if $(BUILD_STATIC),-DCURL_STATICLIB,)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # Build test script
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef

