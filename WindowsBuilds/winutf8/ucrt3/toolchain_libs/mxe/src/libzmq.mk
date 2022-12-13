# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libzmq
$(PKG)_WEBSITE  := https://github.com/zeromq/libzmq
$(PKG)_DESCR    := ZeroMQ core engine in C++, implements ZMTP/3.0
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := c59104a
$(PKG)_CHECKSUM := b6aafd1451d62244a565aadad46c3fcb8c7bf6275963f7e79fb1ef7c9fd1afb4
$(PKG)_GH_CONF  := zeromq/libzmq/branches/master
$(PKG)_DEPS     := cc libsodium

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DBUILD_TESTS=OFF \
        -DCMAKE_CXX_FLAGS='-D_WIN32_WINNT=0x0600' \
        -DWITH_DOC=OFF \
        -DWITH_LIBSODIUM=ON \
        -DWITH_PERF_TOOL=OFF \
        -DZMQ_HAVE_IPC=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Requires: libsodium'; \
     echo 'Libs: -lzmq'; \
     echo 'Libs.private: -lws2_32 -lrpcrt4 -liphlpapi'; \
     echo 'Cflags.private: -DZMQ_STATIC';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # test pkg-config
    '$(TARGET)-g++' \
        -W -Wall -Werror -pedantic \
        '$(SOURCE_DIR)/tools/curve_keygen.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`

    # test cmake
    mkdir '$(BUILD_DIR).test-cmake'
    cd '$(BUILD_DIR).test-cmake' && '$(TARGET)-cmake' \
        -DPKG=$(PKG) \
        -DPKG_VERSION=$($(PKG)_VERSION) \
        -DCMAKE_PREFIX_PATH='$(PREFIX)/$(TARGET)/lib/cmake/zmq' \
        '$(PWD)/src/cmake/test'
    $(MAKE) -C '$(BUILD_DIR).test-cmake' -j 1 install
endef
