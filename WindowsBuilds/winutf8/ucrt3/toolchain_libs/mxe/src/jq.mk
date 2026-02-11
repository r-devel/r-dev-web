
PKG             := jq
$(PKG)_DESCR    := Jq command-line JSON processor
$(PKG)_WEBSITE  := https://stedolan.github.io/jq
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.8.1
$(PKG)_CHECKSUM := 2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0
$(PKG)_SUBDIR   := jq-$($(PKG)_VERSION)
$(PKG)_FILE     := jq-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://github.com/stedolan/jq/releases/download/$($(PKG)_SUBDIR)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(1)' && autoreconf -i -f
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-docs \
        --disable-maintainer-mode \
        --with-oniguruma=builtin \
        $(if $(MXE_IS_LLVM),CFLAGS="-Wno-implicit-function-declaration")
    $(MAKE) LDFLAGS=-all-static -C '$(1)' -j '$(JOBS)'
    $(MAKE) LDFLAGS=-all-static -C '$(1)' -j '1' install

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Requires.private: oniguruma'; \
     echo 'Libs: -l$(PKG)'; \
     echo 'Libs.private: -lshlwapi'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

endef
