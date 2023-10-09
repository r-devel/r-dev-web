
PKG             := libsbml
$(PKG)_WEBSITE  := http://sbml.org
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.20.2
$(PKG)_CHECKSUM := a196cab964b0b41164d4118ef20523696510bbfd264a029df00091305a1af540
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
endef
