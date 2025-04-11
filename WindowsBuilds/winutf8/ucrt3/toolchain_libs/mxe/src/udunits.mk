
PKG             := udunits
$(PKG)_WEBSITE  := https://www.unidata.ucar.edu/downloads/udunits
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.2.28
$(PKG)_CHECKSUM := 590baec83161a3fd62c00efa66f6113cec8a7c461e3f61a5182167e0cc5d579e
$(PKG)_SUBDIR   := udunits-$($(PKG)_VERSION)
$(PKG)_FILE     := udunits-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://downloads.unidata.ucar.edu/udunits/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc expat

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS)

    # configure assumes that non-GCC compilers are all MSVC and need .lib as
    # suffix
    $(if $(MXE_IS_LLVM), \
        $(SED) -i -e 's!^libext=lib$$!libext=a!g' '$(1)/libtool')

    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
