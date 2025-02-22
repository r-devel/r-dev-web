# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgit2
$(PKG)_WEBSITE  := https://libgit2.github.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.9.0
$(PKG)_CHECKSUM := 75b27d4d6df44bd34e2f70663cfd998f5ec41e680e1e593238bbe517a84c7ed2
$(PKG)_GH_CONF  := libgit2/libgit2/releases/latest,v
$(PKG)_DEPS     := cc libssh2 pcre2 zlib

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DDLLTOOL='$(PREFIX)/bin/$(TARGET)-dlltool' \
        -DBUILD_CLI=OFF \
        -DUSE_SSH=ON \
        -DREGEX_BACKEND=pcre2
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1 || $(MAKE) -C '$(BUILD_DIR)' -j 1 VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix pkg-config file
    $(SED) -i 's!^\(Libs.private:.*\)!\1 -lwinhttp -lwsock32 -lws2_32!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

endef
