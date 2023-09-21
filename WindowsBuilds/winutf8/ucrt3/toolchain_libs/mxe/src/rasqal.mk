
PKG             := rasqal
$(PKG)_WEBSITE  := http://librdf.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.9.33
$(PKG)_CHECKSUM := 6924c9ac6570bd241a9669f83b467c728a322470bf34f4b2da4f69492ccfd97c
$(PKG)_SUBDIR   := rasqal-$($(PKG)_VERSION)
$(PKG)_FILE     := rasqal-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://download.librdf.org/source/$($(PKG)_FILE)
$(PKG)_DEPS     := cc raptor2 pcre2

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        CFLAGS="$(if $(BUILD_STATIC),-DRASQAL_STATIC -DRAPTOR_STATIC)"
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
