# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := file
$(PKG)_WEBSITE  := https://www.darwinsys.com/file/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.46
$(PKG)_CHECKSUM := c9cc77c7c560c543135edc555af609d5619dbef011997e988ce40a3d75d86088
$(PKG)_SUBDIR   := file-$($(PKG)_VERSION)
$(PKG)_FILE     := file-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://astron.com/pub/file/$($(PKG)_FILE)
$(PKG)_URL_2    := https://distfiles.macports.org/file/$($(PKG)_FILE)
$(PKG)_DEPS     := cc libgnurx

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://astron.com/pub/file/' | \
    grep 'file-' | \
    $(SED) -n 's,.*file-\([0-9][^>]*\)\.tar.*,\1,p' | \
    tail -1
endef

define $(PKG)_BUILD
    cd '$(1)' && autoreconf -fi

    # "file" needs a runnable version of the "file" utility
    # itself. This must match the source code regarding its
    # version. Therefore we build a native one ourselves first.

    cp -Rp '$(1)' '$(1).native'
    cd '$(1).native' && ./configure \
        --disable-shared \
        CFLAGS="-Wno-implicit-function-declaration"
    $(MAKE) -C '$(1).native/src' -j '$(JOBS)'

    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        CFLAGS="-DHAVE_PREAD -Wno-implicit-function-declaration -Wno-incompatible-pointer-types"
    $(MAKE) -C '$(1)' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= man_MANS= FILE_COMPILE='$(1).native/src/file'
    $(MAKE) -C '$(1)' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= man_MANS=

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-file.exe' \
        -lmagic -lgnurx -lshlwapi
endef
