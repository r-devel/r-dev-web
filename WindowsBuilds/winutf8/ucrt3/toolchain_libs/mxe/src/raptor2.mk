
PKG             := raptor2
$(PKG)_WEBSITE  := http://librdf.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.0.16
$(PKG)_CHECKSUM := 089db78d7ac982354bdbf39d973baf09581e6904ac4c92a98c5caadb3de44680
$(PKG)_SUBDIR   := raptor2-$($(PKG)_VERSION)
$(PKG)_FILE     := raptor2-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://download.librdf.org/source/$($(PKG)_FILE)
$(PKG)_DEPS     := cc expat libxml2 libxslt curl

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-xml2-config='$(PREFIX)/$(TARGET)/bin/xml2-config' \
        --with-xslt-config='$(PREFIX)/$(TARGET)/bin/xslt-config' \
        --with-curl-config='$(PREFIX)/$(TARGET)/bin/curl-config' \
        CFLAGS="$(if $(BUILD_STATIC),-DRAPTOR_STATIC)"
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
