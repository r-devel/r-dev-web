# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := blas
$(PKG)_WEBSITE  := https://www.netlib.org/blas/
$(PKG)_DESCR    := Reference BLAS (Basic Linear Algebra Subprograms)
$(PKG)_IGNORE    = $(lapack_IGNORE)
$(PKG)_VERSION   = $(lapack_VERSION)
$(PKG)_CHECKSUM  = $(lapack_CHECKSUM)
$(PKG)_SUBDIR    = $(lapack_SUBDIR)
$(PKG)_FILE      = $(lapack_FILE)
$(PKG)_URL       = $(lapack_URL)
$(PKG)_DEPS     := cc fc

define $(PKG)_UPDATE
    echo $(lapack_VERSION)
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
        -DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
        -DCBLAS=OFF \
        -DLAPACKE=OFF \
        -DTEST_FORTRAN_COMPILER:BOOL=OFF
    $(MAKE) -C '$(BUILD_DIR)/BLAS' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)/BLAS' -j 1 install

    # fix pkg-config file
    echo 'Libs.private: \
          $(if $(MXE_IS_LLVM),-lFortranRuntime -lFortranDecimal -lc++, \
                              -lgfortran -lquadmath)' \
      >> $(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc

    '$(TARGET)-gcc' \
        -W -Wall -Werror \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' --cflags --libs $(PKG)`
endef
