# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libssh
$(PKG)_WEBSITE  := https://www.libssh.org
$(PKG)_DESCR    := SSHv2 and SSHv1 protocol on client and server side
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.10.6
$(PKG)_CHECKSUM := 5789613288c3dea7348f51f7de68cd7f54316b063906561f92b44dafb01ae387
$(PKG)_SUBDIR   := libssh-$($(PKG)_VERSION)
$(PKG)_FILE     := libssh-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://git.libssh.org/projects/libssh.git/snapshot/libssh-$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc libgcrypt zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://git.libssh.org/projects/libssh.git/refs/tags' | \
    $(SED) -n "s,.*>libssh-\([0-9]*\.[^<]*\)\.tar.*,\1,p" | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DWITH_STATIC_LIB=$(CMAKE_STATIC_BOOL) \
        -DWITH_SHARED_LIB=$(CMAKE_SHARED_BOOL) \
        -DWITH_BENCHMARKS=OFF \
        -DWITH_CLIENT_TESTING=OFF \
        -DWITH_DEBUG_CALLTRACE=OFF \
        -DWITH_DEBUG_CRYPTO=OFF \
        -DWITH_EXAMPLES=OFF \
        -DWITH_GCRYPT=ON \
        -DWITH_GSSAPI=OFF \
        -DWITH_INTERNAL_DOC=OFF \
        -DWITH_NACL=OFF \
        -DWITH_PCAP=OFF \
        -DWITH_SERVER=ON \
        -DWITH_SFTP=ON \
        -DWITH_SSH1=ON \
        -DWITH_TESTING=OFF \
        -DWITH_ZLIB=ON

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: libssh'; \
     echo 'Requires: libgcrypt zlib'; \
     echo 'Libs: -lssh'; \
     echo 'Libs.private: -liphlpapi -lws2_32 -pthread'; \
     echo 'Cflags.private: -DLIBSSH_STATIC';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's-\(/[^/;]\+\)\+/lib/lib\([[:alnum:]]\+\).a-\2-g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/$(PKG)-config.cmake'

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic -std=c99 $($(PKG)_EXTRA_WARNINGS) \
        $(SOURCE_DIR)/examples/{authentication.c,knownhosts.c,connect_ssh.c,exec.c} \
        -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
