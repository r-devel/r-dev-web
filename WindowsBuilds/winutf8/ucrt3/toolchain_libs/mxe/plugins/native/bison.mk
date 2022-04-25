# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := bison
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.5.3
$(PKG)_CHECKSUM := 2bf85b5f88a5f2fa8069aed2a2dfc3a9f8d15a97e59c713e3906e5fdd982a7c4
$(PKG)_SUBDIR   := bison-$($(PKG)_VERSION)
$(PKG)_FILE     := bison-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://ftp.gnu.org/gnu/bison/$($(PKG)_FILE)
$(PKG)_URL_2    := https://ftpmirror.gnu.org/bison/$($(PKG)_FILE)
$(PKG)_WEBSITE  := https://www.gnu.org/software/bison
$(PKG)_OWNER    := https://github.com/tonytheodore
$(PKG)_TARGETS  := $(BUILD)
$(PKG)_DEPS     := flex

REQUIREMENTS := $(filter-out $(PKG), $(REQUIREMENTS))

# recursive variable so always use literal instead of $(PKG)
BOOTSTRAP_PKGS += $(BUILD)~bison

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ftp.gnu.org/gnu/bison/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="bison-\([0-9][^"]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_$(BUILD)
    $(AUTOTOOLS_BUILD)
endef
