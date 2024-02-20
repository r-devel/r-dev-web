# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgit2
$(PKG)_WEBSITE  := https://libgit2.github.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.7.2
$(PKG)_CHECKSUM := de384e29d7efc9330c6cdb126ebf88342b5025d920dcb7c645defad85195ea7f
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
