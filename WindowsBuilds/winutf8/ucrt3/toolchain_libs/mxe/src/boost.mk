# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := boost
$(PKG)_WEBSITE  := https://www.boost.org/
$(PKG)_DESCR    := Boost C++ Library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.88.0
$(PKG)_CHECKSUM := 46d9d2c06637b219270877c9e16155cbd015b6dc84349af064c088e9b5b12f7b
$(PKG)_SUBDIR   := boost_$(subst .,_,$($(PKG)_VERSION))
$(PKG)_FILE     := boost_$(subst .,_,$($(PKG)_VERSION)).tar.bz2
$(PKG)_URL      := https://$(SOURCEFORGE_MIRROR)/project/boost/boost/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL_2    := https://archives.boost.io/release/$($(PKG)_VERSION)/source/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc bzip2 expat zlib

$(PKG)_DEPS_$(BUILD) := zlib

$(PKG)_SUFFIX = $(strip \
                -mt-$(if $(findstring x86_64,$(TARGET)),x64, \
                    $(if $(findstring aarch64,$(TARGET)),a64,x32)))

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.boost.org/users/download/' | \
    $(SED) -n 's,.*/release/\([0-9][^"/]*\)/.*,\1,p' | \
    grep -v beta | \
    head -1
endef

# cross-build, see b2 options at:
# https://www.boost.org/build/doc/html/bbv2/overview/invocation.html
define $(PKG)_B2_CROSS_BUILD
    cd '$(SOURCE_DIR)' && ./tools/build/b2 \
        --ignore-site-config \
        --user-config=user-config.jam \
        abi=ms \
        address-model=$(BITS) \
        architecture="$(if $(findstring aarch64,$(TARGET)),arm,x86)" \
        $(if $(findstring aarch64,$(TARGET)),--without-context --without-coroutine --without-fiber) \
        binary-format=pe \
        link=$(if $(BUILD_STATIC),static,shared) \
        target-os=windows \
        threadapi=win32 \
        threading=multi \
        variant=release \
        toolset=gcc-mxe \
        --layout=tagged \
        --disable-icu \
        --without-mpi \
        --without-python \
        --prefix='$(PREFIX)/$(TARGET)' \
        --exec-prefix='$(PREFIX)/$(TARGET)/bin' \
        --libdir='$(PREFIX)/$(TARGET)/lib' \
        --includedir='$(PREFIX)/$(TARGET)/include' \
        -sEXPAT_INCLUDE='$(PREFIX)/$(TARGET)/include' \
        -sEXPAT_LIBPATH='$(PREFIX)/$(TARGET)/lib' \
        install
endef

define $(PKG)_BUILD
    # old version appears to interfere
    rm -rf '$(PREFIX)/$(TARGET)/include/boost/'
    rm -f "$(PREFIX)/$(TARGET)/lib/libboost"*

    # create user-config
    echo 'using gcc : mxe : $(TARGET)-g++ : <rc>$(TARGET)-windres <archiver>$(TARGET)-ar <ranlib>$(TARGET)-ranlib ;' > '$(SOURCE_DIR)/user-config.jam'

    # compile boost build (b2)
    cd '$(SOURCE_DIR)/tools/build/' && ./bootstrap.sh

    # retry if parallel build fails
    $($(PKG)_B2_CROSS_BUILD) -a -j '$(JOBS)' \
    || $($(PKG)_B2_CROSS_BUILD) -j '1'

    $(if $(BUILD_SHARED), \
        mv -fv '$(PREFIX)/$(TARGET)/lib/'libboost_*.dll '$(PREFIX)/$(TARGET)/bin/')

    # setup cmake toolchain
    echo 'set(Boost_THREADAPI "win32")' > '$(CMAKE_TOOLCHAIN_DIR)/$(PKG).cmake'
    
    # context implementation for aarch64 is not yet available, but used by
    # the example
    $(if $(findstring aarch64,$(TARGET)),,\
        '$(TARGET)-g++' \
            -W -Wall -Werror -ansi -pedantic -std=c++11 \
            '$(PWD)/src/$(PKG)-test.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-boost.exe' \
            -DBOOST_THREAD_USE_LIB \
            -lboost_serialization$($(PKG)_SUFFIX) \
            -lboost_thread$($(PKG)_SUFFIX) \
            -lboost_system$($(PKG)_SUFFIX) \
            -lboost_chrono$($(PKG)_SUFFIX) \
            -lboost_context$($(PKG)_SUFFIX); \
        \
        mkdir '$(BUILD_DIR).test-cmake'; \
        cd '$(BUILD_DIR).test-cmake' && '$(TARGET)-cmake' \
            -DPKG=$(PKG) \
            -DPKG_VERSION=$($(PKG)_VERSION) \
            '$(PWD)/src/cmake/test'; \
        $(MAKE) -C '$(BUILD_DIR).test-cmake' -j 1 install \
    )
endef

define $(PKG)_BUILD_$(BUILD)
    # old version appears to interfere
    rm -rf '$(PREFIX)/$(TARGET)/include/boost/'
    rm -f "$(PREFIX)/$(TARGET)/lib/libboost"*

    # compile boost build (b2)
    cd '$(SOURCE_DIR)/tools/build/' && ./bootstrap.sh

    # minimal native build - for more features, replace:
    # --with-system \
    # --with-filesystem \
    #
    # with:
    # --without-mpi \
    # --without-python \

    cd '$(SOURCE_DIR)' && \
        $(if $(call seq,darwin,$(OS_SHORT_NAME)),PATH=/usr/bin:$$PATH) \
        ./tools/build/b2 \
            -a \
            -q \
            -j '$(JOBS)' \
            --ignore-site-config \
            variant=release \
            link=static \
            threading=multi \
            runtime-link=static \
            --disable-icu \
            --with-system \
            --with-filesystem \
            --build-dir='$(BUILD_DIR)' \
            --prefix='$(PREFIX)/$(TARGET)' \
            --exec-prefix='$(PREFIX)/$(TARGET)/bin' \
            --libdir='$(PREFIX)/$(TARGET)/lib' \
            --includedir='$(PREFIX)/$(TARGET)/include' \
            install
endef
