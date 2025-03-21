PKG             := grpc
$(PKG)_WEBSITE  := https://grpc.io/
$(PKG)_DESCR    := gRPC
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.70.1
$(PKG)_CHECKSUM := c4e85806a3a23fd2a78a9f8505771ff60b2beef38305167d50f5e8151728e426
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
