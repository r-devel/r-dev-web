# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := geos
$(PKG)_WEBSITE  := https://libgeos.org/
$(PKG)_DESCR    := GEOS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.13.1
$(PKG)_CHECKSUM := df2c50503295f325e7c8d7b783aca8ba4773919cde984193850cf9e361dfd28c
$(PKG)_SUBDIR   := geos-$($(PKG)_VERSION)
$(PKG)_FILE     := geos-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://download.osgeo.org/geos/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://download.osgeo.org/geos/' | \
    $(SED) -n 's,.*geos-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc' | \
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
