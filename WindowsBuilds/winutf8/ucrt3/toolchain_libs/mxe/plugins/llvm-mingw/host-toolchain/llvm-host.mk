# This file is part of MXE. See LICENSE.md for licensing information.
# based on https://github.com/libvips/build-win64-mxe/blob/master/build/plugins/llvm-mingw/llvm.mk
# and https://github.com/mstorsjo/llvm-mingw

PKG             := llvm-host
$(PKG)_WEBSITE  := $(llvm_WEBSITE)
$(PKG)_DESCR    := $(llvm_DESCR)
$(PKG)_IGNORE   := $(llvm_IGNORE)
$(PKG)_VERSION  := $(llvm_VERSION)
$(PKG)_CHECKSUM := $(llvm_CHECKSUM)
$(PKG)_PATCHES  := $(llvm_PATCHES)
$(PKG)_GH_CONF  := $(llvm_GH_CONF)
$(PKG)_SUBDIR   := $(llvm_SUBDIR)
$(PKG)_FILE     := $(llvm_FILE)
$(PKG)_URL      := $(llvm_URL)
$(PKG)_DEPS     := llvm llvm-mingw

define $(PKG)_UPDATE
    echo $(llvm_VERSION)
endef

define $(PKG)_BUILD

    mkdir '$(BUILD_DIR).host'
    cd '$(BUILD_DIR).host' && cmake '$(SOURCE_DIR)/llvm' \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(BUILD)' \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=$(PREFIX)/$(BUILD)/bin/$(BUILD_CC) \
        -DCMAKE_CXX_COMPILER=$(PREFIX)/$(BUILD)/bin/$(BUILD_CXX) \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_ENABLE_PROJECTS='clang;mlir;flang;lld;clang-tools-extra' \
        -DLLVM_TARGETS_TO_BUILD='AArch64' \
        -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_DOXYGEN=OFF \
        -DLLVM_ENABLE_OCAMLDOC=OFF \
        -DLLVM_ENABLE_SPHINX=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLDB_ENABLE_LIBEDIT=OFF \
        -DLLDB_ENABLE_PYTHON=OFF \
        -DLLDB_ENABLE_CURSES=OFF \
        -DLLDB_ENABLE_LUA=OFF \
        -DLLDB_INCLUDE_TESTS=OFF \
        -DHAVE_STEADY_CLOCK=0
    $(MAKE) -C '$(BUILD_DIR).host' llvm-tblgen clang-tblgen
    $(MAKE) -C '$(BUILD_DIR).host/tools/mlir'

    # These options make tools like clang*exe and llvm*exe dynamically
    # linked to common LLVM code, which saves a lot of space. But, for some
    # reason, clang-16 then isn't able to read the include files (not sure
    # why) when compiling on the target.
    #   -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON

    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)/llvm' \
        -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_ENABLE_PROJECTS='clang;lld;lldb;flang;mlir' \
        -DLLVM_TARGETS_TO_BUILD='AArch64' \
        -DLLVM_TOOLCHAIN_TOOLS='llvm-ar;llvm-config;llvm-ranlib;llvm-objdump;llvm-rc;llvm-cvtres;llvm-nm;llvm-strings;llvm-readobj;llvm-dlltool;llvm-pdbutil;llvm-objcopy;llvm-strip;llvm-cov;llvm-profdata;llvm-addr2line;llvm-symbolizer;llvm-windres' \
        -DLLVM_BUILD_DOCS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_ENABLE_DOXYGEN=OFF \
        -DLLVM_ENABLE_OCAMLDOC=OFF \
        -DLLVM_ENABLE_SPHINX=OFF \
        -DLLVM_HOST_TRIPLE=aarch64-w64-mingw32 \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
        -DLLVM_USE_LINKER=lld \
        -DLLDB_ENABLE_LIBEDIT=OFF \
        -DLLDB_ENABLE_PYTHON=OFF \
        -DLLDB_ENABLE_CURSES=OFF \
        -DLLDB_ENABLE_LUA=OFF \
        -DLLDB_INCLUDE_TESTS=OFF \
        -DMLIR_LINALG_ODS_YAML_GEN='$(BUILD_DIR).host/bin/mlir-linalg-ods-yaml-gen' \
        -DMLIR_TABLEGEN='$(BUILD_DIR).host/bin/mlir-tblgen' \
        -DLLVM_TABLEGEN='$(BUILD_DIR).host/bin/llvm-tblgen' \
        -DCLANG_TABLEGEN='$(BUILD_DIR).host/bin/clang-tblgen' \
        -DHAVE_STEADY_CLOCK=0

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(subst -,/,$(INSTALL_STRIP_TOOLCHAIN))

    ## the original llvm-mingw instead copies some of these files from the
    ## cross-toolchain build, but it would be difficult here as the
    ## installation already includes different files

    $(eval CLANG_RESOURCE_DIR := \
        '$(PREFIX)/$(TARGET)/lib/clang/$(shell echo $($(PKG)_VERSION) | cut -d . -f1)')

    mkdir '$(BUILD_DIR).compiler-rt'
    cd '$(BUILD_DIR).compiler-rt' && $(TARGET)-cmake '$(SOURCE_DIR)/compiler-rt/lib/builtins' \
        -DCMAKE_INSTALL_PREFIX='$(CLANG_RESOURCE_DIR)' \
        -DCMAKE_AR='$(PREFIX)/$(BUILD)/bin/llvm-ar' \
        -DCMAKE_RANLIB='$(PREFIX)/$(BUILD)/bin/llvm-ranlib' \
        -DCMAKE_C_COMPILER_TARGET='$(PROCESSOR)-w64-windows-gnu' \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=TRUE \
        -DCOMPILER_RT_USE_BUILTINS_LIBRARY=TRUE
    $(MAKE) -C '$(BUILD_DIR).compiler-rt' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR).compiler-rt' -j 1 $(subst -,/,$(INSTALL_STRIP_TOOLCHAIN))
   
endef
