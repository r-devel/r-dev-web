# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtvirtualkeyboard
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 376880f79135dfde95b636d251b1b88667f2ba4fedbca8d702b3283ba45b5e22
$(PKG)_SUBDIR    = $(subst qtbase,qtvirtualkeyboard,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtvirtualkeyboard,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtvirtualkeyboard,$(qtbase_URL))
$(PKG)_DEPS     := cc qtbase qtdeclarative qtmultimedia qtquickcontrols qtsvg

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
