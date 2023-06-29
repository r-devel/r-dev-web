# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := giflib
$(PKG)_WEBSITE  := https://sourceforge.net/projects/libungif/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.1.9
$(PKG)_CHECKSUM := 292b10b86a87cb05f9dcbe1b6c7b99f3187a106132dd14f1ba79c90f561c3295
$(PKG)_SUBDIR   := giflib-$($(PKG)_VERSION)
$(PKG)_FILE     := giflib-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://$(SOURCEFORGE_MIRROR)/project/giflib/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://sourceforge.net/projects/giflib/files/' | \
    grep '<a href.*giflib.*bz2/download' | \
    $(SED) -n 's,.*giflib-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    echo 'all:' > '$(1)/doc/Makefile'
    $(SED) -i 's!PREFIX = /usr/local!PREFIX =!g' '$(1)/Makefile'

    for tgt in libgif.a libgif.so install-include install-lib ; do \
        CC='$(TARGET)-gcc' \
        AR='$(TARGET)-ar' \
        DESTDIR='$(PREFIX)/$(TARGET)' \
        $(MAKE) -C '$(1)' -j '$(JOBS)' $$tgt ; \
    done

    $(if $(BUILD_SHARED),\
         rm -f '$(PREFIX)/$(TARGET)/lib/libgif.a',\
         rm -f '$(PREFIX)/$(TARGET)/lib/libgif.so.*', \
         rm -f '$(PREFIX)/$(TARGET)/lib/libgif.so*')
endef
