# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgit2
$(PKG)_WEBSITE  := https://libgit2.github.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.8.1
$(PKG)_CHECKSUM := 8c1eaf0cf07cba0e9021920bfba9502140220786ed5d8a8ec6c7ad9174522f8e
$(PKG)_GH_CONF  := libgit2/libgit2/releases/latest,v
$(PKG)_DEPS     := cc libssh2

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DDLLTOOL='$(PREFIX)/bin/$(TARGET)-dlltool' \
        -DBUILD_CLI=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1 || $(MAKE) -C '$(BUILD_DIR)' -j 1 VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix pkg-config file
    $(SED) -i 's!^\(Libs.private:.*\)!\1 -lwinhttp -lwsock32 -lws2_32!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

endef
