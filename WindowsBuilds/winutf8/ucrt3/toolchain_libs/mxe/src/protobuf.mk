# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := protobuf
$(PKG)_WEBSITE  := https://github.com/google/protobuf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 25.5
$(PKG)_CHECKSUM := 3cf7d5b17c4ff04fe9f038104e9d0cae6da09b8ce271c13e44f8ac69f51e4e0f
$(PKG)_GH_CONF  := google/protobuf/tags,v
$(PKG)_DEPS     := cc zlib abseil-cpp json-c
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS_$(BUILD) := cmake zlib abseil-cpp json-c

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
        -Dprotobuf_BUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_ABSL_PROVIDER="package" \
        -Dprotobuf_JSONCPP_PROVIDER="package" \
        -Dprotobuf_WITH_ZLIB=ON \
        -DCMAKE_PREFIX_PATH='$(PREFIX)/$(TARGET)/lib/' \
        $(if $(BUILD_CROSS), \
            -DProtobuf_PROTOC_EXECUTABLE='$(PREFIX)/$(BUILD)/bin/protoc' \
        )
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    $(if $(BUILD_CROSS),
        '$(TARGET)-g++' \
            -W -Wall -Werror -ansi -pedantic -std=c++17 \
            '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-protobuf.exe' \
            `'$(TARGET)-pkg-config' protobuf --cflags --libs`
    )
endef
