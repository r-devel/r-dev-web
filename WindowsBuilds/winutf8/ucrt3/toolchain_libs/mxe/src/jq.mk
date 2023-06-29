
PKG             := jq
$(PKG)_WEBSITE  := https://stedolan.github.io/jq
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.6
$(PKG)_CHECKSUM := 5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72
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
        $(if $(IS_LLVM),CFLAGS="-Wno-implicit-function-declaration")
    $(MAKE) LDFLAGS=-all-static -C '$(1)' -j '$(JOBS)'
    $(MAKE) LDFLAGS=-all-static -C '$(1)' -j '1' install
endef
