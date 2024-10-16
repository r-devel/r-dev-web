# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := openblas
$(PKG)_WEBSITE  := https://www.openblas.net/
$(PKG)_DESCR    := OpenBLAS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.3.28
$(PKG)_CHECKSUM := f1003466ad074e9b0c8d421a204121100b0751c96fc6fcf3d1456bd12f8a00a1
$(PKG)_GH_CONF  := xianyi/OpenBLAS/releases/latest,v
$(PKG)_DEPS     := cc fc pthreads

# openblas has it's own optimised versions of netlib lapack that
# it bundles into -lopenblas so won't conflict with those libs
# headers do conflict so install to separate directory

$(PKG)_MAKE_OPTS = \
        PREFIX='$(PREFIX)/$(TARGET)' \
        OPENBLAS_INCLUDE_DIR='$(PREFIX)/$(TARGET)/include/openblas' \
        CROSS_SUFFIX='$(TARGET)-' \
        FC='$(TARGET)-$(if $(MXE_IS_LLVM),flang,gfortran)' \
        CC='$(TARGET)-$(if $(MXE_IS_LLVM),clang,gcc)' \
        HOSTCC='$(BUILD_CC)' \
        MAKE_NB_JOBS=-1 \
        CROSS=1 \
        BUILD_RELAPACK=1 \
        USE_THREAD=1 \
        USE_OPENMP=1 \
        NUM_THREADS=$(call LIST_NMAX, 2 $(NPROCS)) \
        TARGET=$(if $(findstring aarch64,$(TARGET)),CORTEXA53,CORE2) \
        DYNAMIC_ARCH=$(if $(findstring aarch64,$(TARGET)),0,1) \
        ARCH=$(strip \
             $(if $(findstring x86_64,$(TARGET)),x86_64,\
             $(if $(findstring i686,$(TARGET)),x86,\
             $(if $(findstring aarch64,$(TARGET)),aarch64)))) \
        BINARY=$(BITS) \
        $(if $(BUILD_STATIC),NO_SHARED=1) \
        $(if $(BUILD_SHARED),NO_STATIC=1) \
        EXTRALIB="`'$(TARGET)-pkg-config' --libs pthreads` -fopenmp \
                    $(if $(MXE_IS_LLVM),-lFortranRuntime -lFortranDecimal -lc++, \
                                        -lgfortran -lquadmath)"

define $(PKG)_BUILD
    $(MAKE) -C '$(SOURCE_DIR)' -j '$(JOBS)' $($(PKG)_MAKE_OPTS)
    $(MAKE) -C '$(SOURCE_DIR)' -j 1 install $($(PKG)_MAKE_OPTS)

    # fix cmake file
    $(SED) -i -e 's!\(OpenBLAS_LIBRARIES[ \t]\+\)[^ \t()]\+\(.*\)!\1'"`'$(TARGET)-pkg-config' --libs $(PKG)`"'\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/OpenBLASConfig.cmake'

    # fix cmake file, use relative path for include directory
    $(SED) -i -e 's!\(OpenBLAS_INCLUDE_DIRS[ \t]\+\)[^ \t()]\+\(.*\)!\1"$${CMAKE_CURRENT_LIST_DIR}/../../../include/openblas"\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/OpenBLASConfig.cmake'

    '$(TARGET)-gcc' \
        -W -Wall -Werror \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' --cflags --libs $(PKG)`

    # set BLA_VENDOR and -fopenmp to find openblas
    mkdir '$(BUILD_DIR).test-cmake'
    cd '$(BUILD_DIR).test-cmake' && '$(TARGET)-cmake' \
        -DPKG=$(PKG) \
        -DBLA_VENDOR=OpenBLAS \
        -DCMAKE_C_FLAGS=-fopenmp \
        '$(PWD)/src/cmake/test'
    $(MAKE) -C '$(BUILD_DIR).test-cmake' -j 1 install
endef
