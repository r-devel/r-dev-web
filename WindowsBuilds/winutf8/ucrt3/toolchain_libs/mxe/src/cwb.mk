
PKG             := cwb
$(PKG)_WEBSITE  := https://sourceforge.net/projects/cwb/
$(PKG)_DESCR    := IMS Open Corpus Workbench
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.4.22
$(PKG)_CHECKSUM := aeffd1290dd8b509b2ecc4c565440d64584e99cc674ca5ddd352d85c247c13b9
$(PKG)_SUBDIR   := cwb-$($(PKG)_VERSION)
$(PKG)_FILE     := cwb-$($(PKG)_VERSION)-source.tar.gz
$(PKG)_URL      := https://sourceforge.net/projects/cwb/files/cwb/cwb-3.4-beta/$($(PKG)_FILE)
$(PKG)_DEPS     := cc pcre libiconv expat gettext libffi glib libxml2

CWB_ENVVARS = \
        CC=$(TARGET)-gcc \
        CXX=$(TARGET)-g++ \
        RANLIB=$(TARGET)-ranlib \
        AR="$(TARGET)-ar crs" \
        LD=$(TARGET)-ld \
        RC=$(TARGET)-windres \
        RELEASE_ARCH=x86_64 \
        PLATFORM=mingw-cross \
        MINGW_CROSS_HOME='$(PREFIX)/$(TARGET)'

define $(PKG)_BUILD
    # See https://github.com/PolMine/RcppCWB/blob/master/prep/crosscompilation.Rmd
    # https://github.com/PolMine/libcl
    #
    # FIXME: there are still some changes mentioned not applied here
    #        this may not currently be functional with RcppCWB, etc

    $(MAKE) -C '$(1)' -j 1 $(CWB_ENVVARS) cl cqp utils

    $(INSTALL) -m644  '$(1)/cl/libcl.a' '$(PREFIX)/$(TARGET)/lib'
    $(INSTALL) -m644  '$(1)/utils/libcwb.a' '$(PREFIX)/$(TARGET)/lib'
    $(INSTALL) -m644  '$(1)/cqp/libcqp.a' '$(PREFIX)/$(TARGET)/lib'

    # It is not clear how to install the headers, though

    $(INSTALL) -d  '$(PREFIX)/$(TARGET)/include/cwb/cl'
    $(INSTALL) -m644  '$(1)/cl'/*.h '$(PREFIX)/$(TARGET)/include/cwb/cl'
    $(INSTALL) -d  '$(PREFIX)/$(TARGET)/include/cwb/cqp'
    $(INSTALL) -m644  '$(1)/cqp'/*.h '$(PREFIX)/$(TARGET)/include/cwb/cqp'
    $(INSTALL) -d  '$(PREFIX)/$(TARGET)/include/cwb/CQi'
    $(INSTALL) -m644  '$(1)/CQi'/*.h '$(PREFIX)/$(TARGET)/include/cwb/CQi'

    # https://github.com/PolMine/libcl
    # has a different cl.h file in "include" from "include/cwb/cl"

    $(INSTALL) -m644  '$(1)/cl'/cl.h '$(PREFIX)/$(TARGET)/include'

endef
