# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := nghttp2
$(PKG)_WEBSITE  := https://nghttp2.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.65.0
$(PKG)_CHECKSUM := 8ca4f2a77ba7aac20aca3e3517a2c96cfcf7c6b064ab7d4a0809e7e4e9eb9914
$(PKG)_FILE     := nghttp2-$($(PKG)_VERSION).tar.gz
$(PKG)_GH_CONF  := nghttp2/nghttp2/releases/tags,v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS) \
        --enable-lib-only \
        --without-jemalloc \
        --without-libxml2
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_DOCS)
    $(if $(BUILD_STATIC),$(SED) -i 's/^\(Cflags:.* \)/\1 -DNGHTTP2_STATICLIB /g' '$(BUILD_DIR)/lib/libnghttp2.pc')
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install $(MXE_DISABLE_DOCS)
endef
