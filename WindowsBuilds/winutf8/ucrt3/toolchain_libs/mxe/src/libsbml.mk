
PKG             := libsbml
$(PKG)_WEBSITE  := http://sbml.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.19.0
$(PKG)_CHECKSUM := a7f0e18be78ff0e064e4cdb1cd86634d08bc33be5250db4a1878bd81eeb8b547
$(PKG)_SUBDIR   := libSBML-$($(PKG)_VERSION)-Source
$(PKG)_FILE     := libSBML-$($(PKG)_VERSION)-core-plus-packages-src.tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/sbml/files/libsbml/$($(PKG)_VERSION)/stable/libSBML-$($(PKG)_VERSION)-core-plus-packages-src.tar.gz/download
$(PKG)_DEPS     := cc libxml2

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-libxml='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1)' -j 1 install
#    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
