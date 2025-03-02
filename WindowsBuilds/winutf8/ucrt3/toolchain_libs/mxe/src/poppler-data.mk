# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := poppler-data
$(PKG)_WEBSITE  := https://poppler.freedesktop.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.4.12
$(PKG)_CHECKSUM := c835b640a40ce357e1b83666aabd95edffa24ddddd49b8daff63adb851cdab74
$(PKG)_SUBDIR   := poppler-data-$($(PKG)_VERSION)
$(PKG)_FILE     := poppler-data-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://poppler.freedesktop.org/$($(PKG)_FILE)
$(PKG)_DEPS     :=

define $(PKG)_UPDATE
    $(call GET_LATEST_VERSION, https://poppler.freedesktop.org,poppler-data-)
endef

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)' && $(MAKE) \
      prefix=$(PREFIX)/$(TARGET) \
      install
endef
