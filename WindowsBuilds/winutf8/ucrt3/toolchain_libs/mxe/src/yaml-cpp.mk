# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := yaml-cpp
$(PKG)_WEBSITE  := https://github.com/jbeder/yaml-cpp
$(PKG)_DESCR    := A YAML parser and emitter for C++
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := yaml-cpp-0.9.0
$(PKG)_CHECKSUM := 25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a
$(PKG)_GH_CONF  := jbeder/yaml-cpp/tags,
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DYAML_BUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DYAML_CPP_BUILD_TESTS=OFF \
        -DYAML_CPP_BUILD_TOOLS=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j $(JOBS) VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    $(if $(BUILD_STATIC), \
      echo "Cflags.private: -DYAML_CPP_STATIC_DEFINE" >> \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc')

    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic -std=c++11 \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
