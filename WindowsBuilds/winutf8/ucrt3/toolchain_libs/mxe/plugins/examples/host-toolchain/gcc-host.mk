# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gcc-host
$(PKG)_IGNORE    = $(gcc_IGNORE)
$(PKG)_VERSION   = $(gcc_VERSION)
$(PKG)_CHECKSUM  = $(gcc_CHECKSUM)
$(PKG)_SUBDIR    = $(gcc_SUBDIR)
$(PKG)_FILE      = $(gcc_FILE)
$(PKG)_PATCHES   = $(gcc_PATCHES)
$(PKG)_URL       = $(gcc_URL)
$(PKG)_URL_2     = $(gcc_URL_2)
$(PKG)_DEPS     := cc binutils-host gmp isl mpc mpfr pthreads

define $(PKG)_UPDATE
    echo $(gcc_VERSION)
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        --host='$(TARGET)' \
        --target='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --with-native-system-header-dir='$(PREFIX)/$(TARGET)/include' \
        --enable-languages='c,c++,objc,fortran' \
        --enable-version-specific-runtime-libs \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --disable-nls \
        --without-libiconv-prefix \
        $(if $(BUILD_STATIC),--disable-shared) \
        --disable-multilib \
        --without-x \
        --disable-win32-registry \
        --enable-threads=$(MXE_GCC_THREADS) \
        --enable-libgomp \
        --with-{gmp,isl,mpc,mpfr}='$(PREFIX)/$(TARGET)' \
        --enable-libstdcxx-time \
        target_configargs='XCFLAGS=-Wno-format' \
        $($(PKG)_CONFIGURE_OPTS) \
        ac_cv_header_sys_mman_h=no

    # `all-target-libstdc++-v3` sometimes has parallel failure
    ac_cv_header_sys_mman_h=no $(MAKE) glibcxx_cv_c99_complex_cxx11=yes -C '$(BUILD_DIR)' -j '$(JOBS)' all-target-libstdc++-v3 \
      || ac_cv_header_sys_mman_h=no $(MAKE) glibcxx_cv_c99_complex_cxx11=yes  -C '$(BUILD_DIR)' -j 1 all-target-libstdc++-v3
    ac_cv_header_sys_mman_h=no $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(INSTALL_STRIP_TOOLCHAIN)

    # shared libgcc isn't installed to version-specific locations
    # so install correctly to simplify cleanup (see gcc.mk)
    $(and $(BUILD_SHARED),
    $(MAKE) -C '$(BUILD_DIR)/$(TARGET)/libgcc' -j 1 \
        toolexecdir='$(PREFIX)/$(TARGET)/bin' \
        SHLIB_SLIBDIR_QUAL= \
        install-shared
    -rm -v '$(PREFIX)/$(TARGET)/lib/gcc/$(TARGET)/'libgcc_s*.dll
    -rm -v '$(PREFIX)/$(TARGET)/lib/gcc/$(TARGET)/lib/'libgcc_s*.a
    -rmdir '$(PREFIX)/$(TARGET)/lib/gcc/$(TARGET)/lib/')

    # ensure gomp specs have -ldl (gcc 13.2.0 does not)
    $(SED) -i 's!^\(\*link_gomp:.*-lgomp\)[ \t]*$$!\1 -ldl!g' \
              '$(PREFIX)/$(TARGET)/lib/gcc/$(TARGET)/$($(PKG)_VERSION)/libgomp.spec'

    # ensure liblto_plugin.dll is where binutils will find it
    cp -p '$(PREFIX)/$(TARGET)/libexec/gcc/$(TARGET)/$($(PKG)_VERSION)/liblto_plugin.dll' \
          '$(PREFIX)/$(TARGET)/lib/bfd-plugins'

    # test compilation on host
    # strip and compare cross and host-built tests
    cp '$(TOP_DIR)/src/pthreads-libgomp-test.c' '$(PREFIX)/$(TARGET)/bin/test-$(PKG).c'
    (printf 'set PATH=..\\bin;%%PATH%%\r\n'; \
     printf 'gcc test-$(PKG).c -o test-$(PKG).exe -fopenmp -v\r\n'; \
     printf 'test-$(PKG).exe\r\n'; \
     printf 'strip test-$(PKG).exe test-pthreads-libgomp.exe\r\n'; \
     printf 'fc /b test-$(PKG).exe test-pthreads-libgomp.exe\r\n'; \
     printf 'cmd\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-$(PKG).bat'
endef
