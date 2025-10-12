PKG             := grpc
$(PKG)_WEBSITE  := https://grpc.io/
$(PKG)_DESCR    := gRPC
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.70.2
$(PKG)_CHECKSUM := 92f240f7267ed6cd8ba2be4c59a3b5b6ec0c4b4c466071b1e1d62165b25acf64
$(PKG)_GH_CONF  := grpc/grpc/tags,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc abseil-cpp zlib protobuf openssl c-ares re2 \
                   opencensus-proto $(BUILD)~$(PKG)
$(PKG)_DEPS_$(BUILD) := abseil-cpp zlib protobuf openssl c-ares re2 \
                        opencensus-proto

define $(PKG)_BUILD
    $(call PREPARE_PKG_SOURCE,opencensus-proto,$(SOURCE_DIR))
    cd '$(SOURCE_DIR)' && rm -rf third_party/opencensus-proto && \
        mv '$(opencensus-proto_SUBDIR)' third_party/opencensus-proto
    cd '$(BUILD_DIR)' && \
          $(if $(MXE_IS_LLVM),CXXFLAGS="-DSTRSAFE_NO_DEPRECATE") \
          $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)' \
            -DCMAKE_PREFIX_PATH='$(PREFIX)/$(TARGET)/lib/' \
            -DgRPC_ZLIB_PROVIDER="package" \
            -DgRPC_CARES_PROVIDER="package" \
            -DgRPC_RE2_PROVIDER="package" \
            -DgRPC_SSL_PROVIDER="package" \
            -DgRPC_PROTOBUF_PROVIDER="package" \
            -DgRPC_ABSL_PROVIDER="package" \
            -DCMAKE_CXX_STANDARD=17 \
            $(if $(BUILD_CROSS), \
                -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE='$(PREFIX)/$(BUILD)/bin/protoc' \
                -D_gRPC_CPP_PLUGIN='$(PREFIX)/$(BUILD)/bin/grpc_cpp_plugin' \
            ) \
         '$(1)'

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
