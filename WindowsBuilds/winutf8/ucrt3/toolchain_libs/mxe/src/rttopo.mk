# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := rttopo
$(PKG)_WEBSITE  := https://git.osgeo.org/gitea/rttopo/
$(PKG)_DESCR    := RT Topology Library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.1.0
$(PKG)_CHECKSUM := 2e2fcabb48193a712a6c76ac9a9be2a53f82e32f91a2bc834d9f1b4fa9cd879f
$(PKG)_SUBDIR   := librttopo
$(PKG)_FILE     := librttopo-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://git.osgeo.org/gitea/rttopo/librttopo/archive/$($(PKG)_FILE)
$(PKG)_DEPS     := cc geos

define $(PKG)_BUILD
    cd '$(1)' && ./autogen.sh
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-geosconfig='$(PREFIX)/$(TARGET)/bin/geos-config'

    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
