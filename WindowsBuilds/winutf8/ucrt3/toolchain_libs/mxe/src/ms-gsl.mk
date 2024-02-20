# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ms-gsl
$(PKG)_WEBSITE  := https://github.com/microsoft/gsl
$(PKG)_DESCR    := guidelines support library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.0.0
$(PKG)_CHECKSUM := f0e32cb10654fea91ad56bde89170d78cfbf4363ee0b01d8f097de2ba49f6ce9
$(PKG)_GH_CONF  := microsoft/gsl/releases,v
$(PKG)_DEPS     := cc
$(PKG)_SUBDIR   := GSL-$($(PKG)_VERSION)

define $(PKG)_BUILD
    '$(TARGET)-cmake' -S $(SOURCE_DIR) -B $(BUILD_DIR) -DGSL_TEST=0
    $(MAKE) -C '$(BUILD_DIR)' -j $(JOBS)
    $(MAKE) -C '$(BUILD_DIR)' install
endef
