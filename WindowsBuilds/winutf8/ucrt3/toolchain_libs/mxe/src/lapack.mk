# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := lapack
$(PKG)_WEBSITE  := https://www.netlib.org/lapack/
$(PKG)_DESCR    := Reference LAPACK — Linear Algebra PACKage
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.12.0
$(PKG)_CHECKSUM := eac9570f8e0ad6f30ce4b963f4f033f0f643e7c3912fc9ee6cd99120675ad48b
$(PKG)_GH_CONF  := Reference-LAPACK/lapack/tags,v
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc fc cblas

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
        -DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
        -DBLAS_LIBRARIES=blas \
        -DCBLAS=OFF \
        -DLAPACKE=ON \
        -DTEST_FORTRAN_COMPILER=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # fix cmake file, avoid unnecessary absolute path
    $(SED) -i -e 's!\(LAPACKE_INCLUDE_DIRS[ \t]\+\)[^ \t()]\+\(.*\)!\1""\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/lapacke-$($(PKG)_VERSION)/lapacke-config.cmake'

    # if blas/cblas routines are used directly, add to pkg-config call
    '$(TARGET)-gfortran' \
        -Werror -pedantic $(if $(MXE_IS_LLVM),,-W -Wall )\
        '$(PWD)/src/$(PKG)-test.f' -o '$(PREFIX)/$(TARGET)/bin/test-lapack.exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs` \

    # flang cannot compile C code, gfortran can
    $(if $(MXE_IS_LLVM), \
        '$(TARGET)-clang' \
            -W -Wall -Werror -pedantic \
            '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-lapacke.exe' \
            `'$(TARGET)-pkg-config' lapacke cblas --cflags --libs`;, \
        \
    # ---- not LLVM ---- \
        '$(TARGET)-gfortran' \
            -W -Wall -Werror -pedantic \
            '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-lapacke.exe' \
            `'$(TARGET)-pkg-config' lapacke cblas --cflags --libs`;, \
    )
endef
