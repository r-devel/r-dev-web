PKG := mingw-w64
$(PKG)_VERSION  := 11.0.1
$(PKG)_CHECKSUM := 3f66bce069ee8bed7439a1a13da7cb91a5e67ea6170f21317ac7f5794625ee10
$(PKG)_SUBDIR   := $(PKG)-v$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-v$($(PKG)_VERSION).tar.bz2
$(PKG)_PATCHES  := $(filter-out mingw-w64-acces.patch, $($(PKG)_PATCHES))
