# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libsodium
$(PKG)_WEBSITE  := https://download.libsodium.org/doc/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.21
$(PKG)_CHECKSUM := 42e0ca94faaec901f4fbeda84b1b94b18f5309c360c66345cf52a7ab515b245b
$(PKG)_GH_CONF  := jedisct1/libsodium/releases/latest,,-RELEASE
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
