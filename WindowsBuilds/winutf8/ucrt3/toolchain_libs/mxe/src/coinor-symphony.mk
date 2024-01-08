
PKG             := coinor-symphony
$(PKG)_WEBSITE  := https://www.coin-or.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.6.17
$(PKG)_CHECKSUM := ac7c0714cc76a326e427d68f23ddbef35de8828b2fd9a837e8841e8b77856af2
$(PKG)_SUBDIR   := SYMPHONY-$($(PKG)_VERSION)
$(PKG)_FILE     := SYMPHONY-$($(PKG)_VERSION).tgz
$(PKG)_URL      := https://www.coin-or.org/download/source/SYMPHONY/$($(PKG)_FILE)
$(PKG)_DEPS     := cc fc

define $(PKG)_BUILD
    # configure is too old to support docdir and cannot be
    #   re-generated using new autotools
    # configure, make use add things to PKG_CONFIG_PATH during build
    #   to find internal packages during build, which does not work
    #   well with cross-compilation and MXE requires the _target suffix
    #   ... hence, disable use of pkg config during build
    # configure is patched to not bail out from aarch64 builds as it 
    #   cannot be re-generated
    # FLIBS have to be overridden otherwise they are detected incorrectly
    #   with LLVM
    cd '$(1)' && ./configure \
        $(subst docdir$(comma),,$(MXE_CONFIGURE_OPTS)) \
        CXXFLAGS=-std=c++14 \
        PKG_CONFIG=/bin/false \
        $(if $(MXE_IS_LLVM),FLIBS='-lFortranRuntime -lFortranDecimal -lc++')
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
