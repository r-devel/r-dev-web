# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := netcdf
$(PKG)_WEBSITE  := https://www.unidata.ucar.edu/software/netcdf/
$(PKG)_DESCR    := NetCDF
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.9.2
$(PKG)_CHECKSUM := bc104d101278c68b303359b3dc4192f81592ae8640f1aee486921138f7f88cb7
$(PKG)_GH_CONF  := Unidata/netcdf-c/releases,v
$(PKG)_DEPS     := cc curl hdf4 hdf5 jpeg portablexdr zlib libxml2

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DHDF5_USE_STATIC_LIBRARIES=$(CMAKE_STATIC_BOOL) \
        -DENABLE_DOXYGEN=OFF \
        -DENABLE_EXAMPLES=OFF \
        -DENABLE_TESTS=OFF \
        -DBUILD_UTILITIES=OFF \
        -DENABLE_HDF4=ON \
        -DENABLE_HDF4_FILE_TESTS=OFF \
        -DENABLE_NETCDF_4=ON \
        -DUSE_HDF5=ON \
        -DHDF5_C_LIBRARY=$(PREFIX)/$(TARGET)/lib/libhdf5.a \
        -DHDF5_HL_LIBRARY=$(PREFIX)/$(TARGET)/lib/libhdf5_hl.a \
        -DHDF5_INCLUDE_DIR=$(PREFIX)/$(TARGET)/include \
        -DHDF5_VERSION=$(hdf5_VERSION) \
        -DCMAKE_C_FLAGS='$(if $(BUILD_STATIC),-DLIBXML_STATIC,)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # fix hdf5 libraries
    $(SED) -i -e 's!-lhdf5_hl-\(static\|shared\)!-lhdf5_hl!g' \
        '$(PREFIX)/$(TARGET)/bin/nc-config'
    $(SED) -i -e 's!-lhdf5-\(static\|shared\)!-lhdf5!g' \
        '$(PREFIX)/$(TARGET)/bin/nc-config'

    echo "Requires: libxml-2.0" >> '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's-\(/[^/;]\+\)\+/lib/lib\([[:alnum:]]\+\).a-\2-g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/netCDF/netCDFTargets.cmake'

    # compile test, pkg-config support incomplete
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        $(if $(MXE_IS_LLVM),"-Wno-strict-prototypes") \
        '$(SOURCE_DIR)/examples/C/simple.c' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) libjpeg libcurl --cflags --libs` -lportablexdr
endef
