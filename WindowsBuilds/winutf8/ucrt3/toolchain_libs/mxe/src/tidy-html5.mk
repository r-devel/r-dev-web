# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := tidy-html5
$(PKG)_WEBSITE  := https://www.html-tidy.org/
$(PKG)_DESCR    := HTML/XML syntax checker and reformatter
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.9.14-next
$(PKG)_CHECKSUM := 83cc9d9cdfa59bfe400dc745dea14eb1e1be4ca088facfb911eac8b78e75f2b4
$(PKG)_GH_CONF  := htacg/tidy-html5/tags
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DTIDY_COMPAT_HEADERS:BOOL=YES \
        -DBUILD_SHARED_LIB=$(CMAKE_SHARED_BOOL)
    $(MAKE) -C '$(BUILD_DIR)' -j $(JOBS)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    $(if $(BUILD_STATIC),
        cd '$(PREFIX)/$(TARGET)/lib' && mv libtidy_static.a libtidy.a,
        rm -f '$(PREFIX)/$(TARGET)/lib/libtidy_static.a')
    # keep also the executable
    #rm -f '$(PREFIX)/$(TARGET)/bin/tidy.exe'

    # build test manually
    '$(TARGET)-gcc' \
        -W -Wall -Werror \
        '$(PWD)/src/$(PKG)-test.c' \
        -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        -ltidy
endef
