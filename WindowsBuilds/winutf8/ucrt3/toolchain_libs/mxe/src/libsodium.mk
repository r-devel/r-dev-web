# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsodium
$(PKG)_WEBSITE  := https://download.libsodium.org/doc/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.19
$(PKG)_CHECKSUM := 4fb996013283f482f46a457c8ff2c1495e797788e78e8ec56b1aa1b19253bf75
$(PKG)_GH_CONF  := jedisct1/libsodium/releases/latest,,-RELEASE
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
