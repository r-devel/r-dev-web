
PKG             := libsbml
$(PKG)_WEBSITE  := http://sbml.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.20.5
$(PKG)_CHECKSUM := 21c88c753a4a031f157a033de3810488b86f003e684c6ca7aa3d6e26e7e0acfc
$(PKG)_SUBDIR   := libsbml-$($(PKG)_VERSION)
$(PKG)_GH_CONF  := sbmlteam/libsbml/releases/tag,v
$(PKG)_DEPS     := cc libxml2

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake \
        -DLIBXML_INCLUDE_DIR=$(PREFIX)/$(TARGET)/include/libxml2 \
         $(if $(BUILD_STATIC),-DLIBXML_LIBRARY="$(PREFIX)/$(TARGET)/lib/libxml2.a") \
        -DWITH_SWIG=OFF \
        '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    rm -f '$(PREFIX)/$(TARGET)'/bin/libsbml.dll
    rm -f '$(PREFIX)/$(TARGET)'/lib/libsbml.dll.a

    # fix pkg-config file
    $(SED) -i 's!$(PREFIX)/$(TARGET)/lib/lib\([a-zA-Z0-9]\+\)\.a!-l\1!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

endef
