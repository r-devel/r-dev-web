# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsodium
$(PKG)_WEBSITE  := https://download.libsodium.org/doc/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.20
$(PKG)_CHECKSUM := 8e5aeca07a723a27bbecc3beef14b0068d37e7fc0e97f51b3f1c82d2a58005c1
$(PKG)_GH_CONF  := jedisct1/libsodium/releases/latest,,-RELEASE
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
