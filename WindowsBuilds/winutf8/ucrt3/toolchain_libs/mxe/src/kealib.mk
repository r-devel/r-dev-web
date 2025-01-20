PKG             := kealib
$(PKG)_WEBSITE  := https://github.com/ubarsc/kealib
$(PKG)_DESCR    := KEALib
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.6.1
$(PKG)_CHECKSUM := 6c892db9c95d32fa67f927ca37e8019dcbca5146353d69ee8af3e71935115edd
$(PKG)_GH_CONF  := ubarsc/kealib/releases,kealib-
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_DEPS     := cc hdf5

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
            -DCMAKE_BUILD_TYPE="Release" \
            -DHDF5_DIR='$(PREFIX)/$(TARGET)/' \
            -DHDF5_USE_STATIC_LIBRARIES=$(CMAKE_STATIC_BOOL) \
            -DHDF5_FIND_DEBUG=ON \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix hdf5 libraries
    $(SED) -i -e 's!-lhdf5_cpp-\(static\|shared\)!'"`'$(TARGET)-pkg-config' hdf5_cpp --cflags --libs`"'!g' \
        '$(PREFIX)/$(TARGET)/bin/kea-config'
    $(SED) -i -e 's!-lhdf5-\(static\|shared\)!'"`'$(TARGET)-pkg-config' hdf5 --cflags --libs`"'!g' \
        '$(PREFIX)/$(TARGET)/bin/kea-config'

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Requires: hdf5_cpp'; \
     echo 'Libs: -lkea'; \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # Test
    '$(TARGET)-g++' \
        -W -Wall -Werror -pedantic \
        '$(SOURCE_DIR)/src/tests/test1.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-kealib.exe' \
        `'$(PREFIX)/$(TARGET)/bin/kea-config' --cflags --hdfcflags --libs --hdflibs`

    '$(TARGET)-g++' \
        -W -Wall -Werror -pedantic \
        '$(SOURCE_DIR)/src/tests/test1.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-kealib-pkgconf.exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
