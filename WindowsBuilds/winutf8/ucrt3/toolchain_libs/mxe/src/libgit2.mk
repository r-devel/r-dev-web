# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgit2
$(PKG)_WEBSITE  := https://libgit2.github.com/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.9.1
$(PKG)_CHECKSUM := 14cab3014b2b7ad75970ff4548e83615f74d719afe00aa479b4a889c1e13fc00
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

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's!\(/[^/;]\+\)\+/lib/lib\([[:alnum:]_-]\+\).a!\2!g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/$(PKG)/$(PKG)Targets.cmake'

endef
