# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := armadillo
$(PKG)_WEBSITE  := https://arma.sourceforge.io/
$(PKG)_DESCR    := Armadillo C++ linear algebra library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 15.0.3
$(PKG)_CHECKSUM := 9f55ec10f0a91fb6479ab4ed2b37a52445aee917706a238d170b5220c022fe43
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://$(SOURCEFORGE_MIRROR)/project/arma/$($(PKG)_FILE)
$(PKG)_DEPS     := cc hdf5 openblas lapack

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://sourceforge.net/projects/arma/files/' | \
    $(SED) -n 's,.*/armadillo-\([0-9.]*\)[.]tar.*".*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DARMA_HDF5_INCLUDE_DIR=$(PREFIX)/$(TARGET)/include \
        -DDETECT_HDF5=OFF \
        -DARMA_USE_WRAPPER=ON \
	-DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DSTATIC_LIB=$(CMAKE_STATIC_BOOL) \
        -DBUILD_SMOKE_TEST=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Requires: hdf5 openblas'; \
     echo 'Libs: -larmadillo'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/share/Armadillo/CMake/ArmadilloLibraryDepends.cmake'

    # fix cmake file, avoid unnecessary absolute path
    $(SED) -i -e 's!\(ARMADILLO_LIBRARY_DIRS[ \t]\+\)[^ \t()]\+\(.*\)!\1""\2!g' \
                 '$(PREFIX)/$(TARGET)/share/Armadillo/CMake/ArmadilloConfig.cmake'

    # fix cmake file, avoid unnecessary absolute path
    $(SED) -i -e 's!\(ARMADILLO_INCLUDE_DIRS[ \t]\+\)[^ \t()]\+\(.*\)!\1""\2!g' \
                 '$(PREFIX)/$(TARGET)/share/Armadillo/CMake/ArmadilloConfig.cmake'

    # compile test
    '$(TARGET)-g++' \
        -W -Wall -Werror -fopenmp \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
