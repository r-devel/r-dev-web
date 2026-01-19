# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := quantlib
$(PKG)_WEBSITE  := https://www.quantlib.org/
$(PKG)_DESCR    := QuantLib
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.41
$(PKG)_CHECKSUM := c5e9a30fce129660932e643647eb9a14e19ec24344d6b813c57c054187b03bdd
$(PKG)_SUBDIR   := QuantLib-$($(PKG)_VERSION)
$(PKG)_GH_CONF  := lballabio/quantlib/releases,v
$(PKG)_DEPS     := cc boost

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
      -DQL_BUILD_BENCHMARK=OFF \
      -DQL_INSTALL_BENCHMARK=OFF \
      -DQL_BUILD_EXAMPLES=OFF \
      -DQL_INSTALL_EXAMPLES=OFF \
      -DQL_BUILD_TEST_SUITE=OFF \
      -DQL_INSTALL_TEST_SUITE=OFF \
      -DQL_ENABLE_OPENMP=ON \

    # install
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/QuantLib/QuantLibTargets.cmake'
    $(SED) -i -e 's-\(/[^/;]\+\)\+/libgomp.a-gomp-g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/QuantLib/QuantLibTargets.cmake'
    $(SED) -i -e 's-\(/[^/;]\+\)\+/libomp.dll.a-omp-g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/QuantLib/QuantLibTargets.cmake'

    '$(TARGET)-g++' \
        -W -Wall -Werror \
        '$(SOURCE_DIR)/Examples/BasketLosses/BasketLosses.cpp' \
        -o '$(PREFIX)/$(TARGET)/bin/test-quantlib.exe' \
        `'$(TARGET)-pkg-config' quantlib --cflags --libs`
endef
