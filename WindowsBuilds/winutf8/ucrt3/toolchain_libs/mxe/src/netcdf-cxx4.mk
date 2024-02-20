# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := netcdf-cxx4
$(PKG)_WEBSITE  := https://www.unidata.ucar.edu/software/netcdf/
$(PKG)_DESCR    := NetCDF-CXX4
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.3.1
$(PKG)_CHECKSUM := e3fe3d2ec06c1c2772555bf1208d220aab5fee186d04bd265219b0bc7a978edc
$(PKG)_GH_CONF  := Unidata/netcdf-cxx4/releases,v
$(PKG)_DEPS     := cc netcdf

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DENABLE_DOXYGEN=OFF \
        -DNCXX_ENABLE_TESTS=OFF

    # fix hdf5 target/libname mixup
    $(if $(BUILD_SHARED), \
      $(SED) -i -e 's!-lhdf5_hl-\(static\|shared\)!-lhdf5_hl!g' \
          '$(BUILD_DIR)/cxx4/CMakeFiles/netcdf-cxx4.dir/linklibs.rsp'
      $(SED) -i -e 's!-lhdf5-\(static\|shared\)!-lhdf5!g' \
          '$(BUILD_DIR)/cxx4/CMakeFiles/netcdf-cxx4.dir/linklibs.rsp'
    )

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # compile test, pkg-config support incomplete
    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic \
        '$(SOURCE_DIR)/examples/simple_xy_rd.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        -l$(PKG) `'$(TARGET)-pkg-config' netcdf libjpeg libcurl --cflags --libs` -lportablexdr
endef
