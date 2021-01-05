
PKG             := coinor-symphony
$(PKG)_WEBSITE  := https://www.coin-or.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.6.17
$(PKG)_CHECKSUM := ac7c0714cc76a326e427d68f23ddbef35de8828b2fd9a837e8841e8b77856af2
$(PKG)_SUBDIR   := SYMPHONY-$($(PKG)_VERSION)
$(PKG)_FILE     := SYMPHONY-$($(PKG)_VERSION).tgz
$(PKG)_URL      := https://www.coin-or.org/download/source/SYMPHONY/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    # configure is too old to support docdir and cannot be
    #   re-generated easily
    # configure, make use add things to PKG_CONFIG_PATH during build
    #   to find internal packages during build, which does not work
    #   well with cross-compilation and MXE requires the _target suffix
    #   ... hence, disable use of pkg config during build
    cd '$(1)' && ./configure \
        $(subst docdir$(comma),,$(MXE_CONFIGURE_OPTS)) \
        PKG_CONFIG=/bin/false
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
