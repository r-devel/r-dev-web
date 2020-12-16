
PKG             := udunits
$(PKG)_WEBSITE  := https://www.unidata.ucar.edu/software/udunits/udunits-current/doc/udunits/udunits2.html
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.2.26
$(PKG)_CHECKSUM := 368f4869c9c7d50d2920fa8c58654124e9ed0d8d2a8c714a9d7fdadc08c7356d
$(PKG)_SUBDIR   := udunits-$($(PKG)_VERSION)
$(PKG)_FILE     := udunits-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := ftp://ftp.unidata.ucar.edu/pub/udunits/$($(PKG)_FILE)
$(PKG)_DEPS     := cc expat

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
