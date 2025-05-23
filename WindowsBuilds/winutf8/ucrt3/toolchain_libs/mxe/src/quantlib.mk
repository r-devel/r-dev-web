# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := quantlib
$(PKG)_WEBSITE  := https://www.quantlib.org/
$(PKG)_DESCR    := QuantLib
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.38
$(PKG)_CHECKSUM := 7280ffd0b81901f8a9eb43bb4229e4de78384fc8bb2d9dcfb5aa8cf8b257b439
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

    '$(TARGET)-g++' \
        -W -Wall -Werror \
        '$(SOURCE_DIR)/Examples/BasketLosses/BasketLosses.cpp' \
        -o '$(PREFIX)/$(TARGET)/bin/test-quantlib.exe' \
        `'$(TARGET)-pkg-config' quantlib --cflags --libs`
endef
