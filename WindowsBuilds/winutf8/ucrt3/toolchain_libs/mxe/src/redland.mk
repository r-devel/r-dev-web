
PKG             := redland
$(PKG)_WEBSITE  := http://librdf.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.17
$(PKG)_CHECKSUM := de1847f7b59021c16bdc72abb4d8e2d9187cd6124d69156f3326dd34ee043681
$(PKG)_SUBDIR   := redland-$($(PKG)_VERSION)
$(PKG)_FILE     := redland-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://download.librdf.org/source/$($(PKG)_FILE)
$(PKG)_DEPS     := cc expat rasqal raptor2 postgresql

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-mysql=no \
        --with-bdb=no \
        --with-sqlite='$(PREFIX)/$(TARGET)/include' \
        --with-postgresql='$(PREFIX)/$(TARGET)/bin/pg_config' \
        --with-threestore=no \
        --with-virtuoso=no \
        CFLAGS="$(if $(BUILD_STATIC),-DRASQAL_STATIC -DRAPTOR_STATIC -DREDLAND_STATIC)"
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
