# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := geos
$(PKG)_WEBSITE  := https://libgeos.org/
$(PKG)_DESCR    := GEOS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.12.1
$(PKG)_CHECKSUM := d6ea7e492224b51193e8244fe3ec17c4d44d0777f3c32ca4fb171140549a0d03
$(PKG)_SUBDIR   := geos-$($(PKG)_VERSION)
$(PKG)_FILE     := geos-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://download.osgeo.org/geos/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://download.osgeo.org/geos/' | \
    $(SED) -n 's,.*geos-\([0-9][^>]*\)\.tar.*,\1,p' | \
    $(SORT) -V | tail -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
      -DCMAKE_BUILD_TYPE=Release  \
      -DBUILD_GEOSOP=OFF \
      -DCMAKE_POSITION_INDEPENDENT_CODE:bool=ON \
      -DBUILD_SHARED_LIBS:bool=$(if $(BUILD_SHARED),ON,OFF)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_PROGRAMS)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(INSTALL_STRIP_LIB)

    ln -sf '$(PREFIX)/$(TARGET)/bin/geos-config' '$(PREFIX)/bin/$(TARGET)-geos-config'

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-geos.exe' \
        `'$(PREFIX)/bin/$(TARGET)-geos-config' --cflags \
            $(if $(BUILD_SHARED),--clibs,--static-clibs)`
endef
