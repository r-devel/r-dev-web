# This file is part of MXE. See LICENSE.md for licensing information.
# based on https://github.com/libvips/build-win64-mxe/blob/master/build/plugins/llvm-mingw/llvm-mingw.mk
# and https://github.com/mstorsjo/llvm-mingw

PKG             := llvm-mingw
$(PKG)_WEBSITE  := https://github.com/mstorsjo/llvm-mingw
$(PKG)_DESCR    := An LLVM/Clang/LLD based mingw-w64 toolchain
$(PKG)_IGNORE   :=
# https://github.com/mstorsjo/llvm-mingw/tarball/7e8bcdc43c8b68dd25d39e583cb41dc21a0d6c22
$(PKG)_VERSION  := 7e8bcdc
$(PKG)_CHECKSUM := 0b588b0510b01186a6a0c7824b96227302f7ffe8a5b1604abc59d5d6db2923cc
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/llvm-mingw-[0-9]*.patch)))
$(PKG)_GH_CONF  := mstorsjo/llvm-mingw/branches/master
$(PKG)_DEPS     := $(BUILD)~llvm mingw-w64

# The minimum Windows version we support is Windows 7, as libc++ uses
# TryAcquireSRWLockExclusive which didn't exist until Windows 7. See:
# https://github.com/mstorsjo/llvm-mingw/commit/dcf34a9a35ee3d490a85bdec02999cf96615d406
# https://github.com/mstorsjo/llvm-mingw/blob/274a30cff5bf96efeb6b6c7a5a4783fa6fda1e69/build-mingw-w64.sh#L19-L20
# Install the headers in $(PREFIX)/$(TARGET)/$(PROCESSOR)-w64-mingw32 since
# we need to distribute the /include and /lib directories
define $(PKG)_BUILD_mingw-w64
    # Unexport target specific compiler / linker flags
    $(eval unexport CFLAGS)
    $(eval unexport CXXFLAGS)
    $(eval unexport LDFLAGS)

    # install the usual wrappers
    $($(PKG)_PRE_BUILD)

    # install mingw-w64 headers
    $(call PREPARE_PKG_SOURCE,mingw-w64,$(BUILD_DIR))
    mkdir '$(BUILD_DIR).headers'
    cd '$(BUILD_DIR).headers' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-headers/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-idl \
        --with-default-msvcrt=ucrt \
        --with-default-win32-winnt=0x601 \
        $(mingw-w64-headers_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR).headers' install

    # build mingw-w64-crt
    mkdir '$(BUILD_DIR).crt'
    cd '$(BUILD_DIR).crt' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-crt/configure' \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --with-default-msvcrt=ucrt \
        @mingw-crt-config-opts@
    $(MAKE) -C '$(BUILD_DIR).crt' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR).crt' -j 1 $(INSTALL_STRIP_TOOLCHAIN)

    # Create empty dummy archives, to avoid failing when the compiler
    # driver adds "-lssp -lssp_nonshared" when linking.
    $(PREFIX)/$(BUILD)/bin/llvm-ar rcs $(PREFIX)/$(TARGET)/lib/libssp.a
    $(PREFIX)/$(BUILD)/bin/llvm-ar rcs $(PREFIX)/$(TARGET)/lib/libssp_nonshared.a

    # build posix threads
    mkdir '$(BUILD_DIR).pthreads'
    cd '$(BUILD_DIR).pthreads' && '$(BUILD_DIR)/$(mingw-w64_SUBDIR)/mingw-w64-libraries/winpthreads/configure' \
        $(MXE_CONFIGURE_OPTS) \
        $(mingw-w64-pthreads_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR).pthreads' -j '$(JOBS)' || $(MAKE) -C '$(BUILD_DIR).pthreads' -j '$(JOBS)'   
    $(MAKE) -C '$(BUILD_DIR).pthreads' -j 1 $(INSTALL_STRIP_TOOLCHAIN)
endef

define $(PKG)_PRE_BUILD
    # setup target wrappers
    $(foreach EXEC, addr2line ar ranlib nm objcopy strings strip windres dlltool, \
        ln -sf '$(PREFIX)/$(BUILD)/bin/llvm-$(EXEC)' '$(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-$(EXEC)'; \
        (echo '#!/bin/sh'; \
         echo 'exec "$(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-$(EXEC)" "$$@"') \
                 > '$(PREFIX)/bin/$(TARGET)-$(EXEC)'; \
        chmod 0755 '$(PREFIX)/bin/$(TARGET)-$(EXEC)';)

    $(SED) -i -e 's|FLAGS="$$FLAGS -fuse-ld=lld"|\0 ; FLAGS="$$FLAGS -pthread"|' \
        '$(SOURCE_DIR)/wrappers/clang-target-wrapper.sh'

    $(foreach EXEC, clang-target ld objdump, \
        $(SED) -i -e 's|^DEFAULT_TARGET=.*|DEFAULT_TARGET=$(PROCESSOR)-w64-mingw32|' \
                  -e 's|^DIR=.*|DIR="$(PREFIX)/$(BUILD)/bin"|' \
                  -e 's|$$FLAGS "$$@"|$$FLAGS --sysroot="$(PREFIX)/$(TARGET)" "$$@"|' \
                  -e 's|$$CCACHE "$$CLANG"|$(MXE_CCACHE_DIR)/bin/ccache "$$CLANG"|' '$(SOURCE_DIR)/wrappers/$(EXEC)-wrapper.sh'; \
        $(INSTALL) -m755 '$(SOURCE_DIR)/wrappers/$(EXEC)-wrapper.sh' '$(PREFIX)/$(BUILD)/bin';)

    cp -p '$(SOURCE_DIR)/wrappers/clang-target-wrapper.sh' \
          '$(SOURCE_DIR)/wrappers/flang-target-wrapper.sh'

    $(foreach EXEC, clang clang++ gcc g++ c++, \
        ln -sf '$(PREFIX)/$(BUILD)/bin/clang-target-wrapper.sh' '$(PREFIX)/bin/$(TARGET)-$(EXEC)'; \
        ln -sf '$(PREFIX)/$(BUILD)/bin/clang-target-wrapper.sh' '$(PREFIX)/$(BUILD)/bin/$(TARGET)-$(EXEC)'; \
        ln -sf '$(PREFIX)/$(BUILD)/bin/clang-target-wrapper.sh' '$(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-$(EXEC)';)

    # flang produced by the build calls into aarch64-w64-mingw32-flang,
    # unless it has that name; so we rename flang to that name, and
    # flang-target-wrapper calls it; consequently, this is inconsistent with
    # clang (the aarch64-w64-mingw32-clang version is a wrapper, but -flang
    # version is not); also, aarch64-w64-mingw32-flang cannot be used
    # directly without passing special arguments to it

    [ -f '$(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-flang' ] || \
        mv '$(PREFIX)/$(BUILD)/bin/flang' \
        '$(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-flang'

    $(SED) -i -e 's|^CLANG="$$DIR/clang"|CLANG="$$DIR/$(PROCESSOR)-w64-mingw32-flang"|' \
           '$(SOURCE_DIR)/wrappers/flang-target-wrapper.sh'

    # always use the default target, because LLVM requires the short version

    $(SED) -i -e 's|\[ "$$TARGET" = "$$BASENAME" \]|true|' \
           '$(SOURCE_DIR)/wrappers/flang-target-wrapper.sh'

    # NOTE: the compiler needs the aarch64 (TARGET) LLVM static libraries,
    # which are however built only with the native compiler
    # (host-toolchain/llvm-mingw-host).

    $(INSTALL) -m755 '$(SOURCE_DIR)/wrappers/flang-target-wrapper.sh' '$(PREFIX)/$(BUILD)/bin'
    $(foreach EXEC, $(PREFIX)/bin/$(TARGET)-flang \
                    $(PREFIX)/$(BUILD)/bin/$(TARGET)-flang \
                    $(PREFIX)/$(BUILD)/bin/flang \
                    $(PREFIX)/bin/$(TARGET)-gfortran \
                    $(PREFIX)/$(BUILD)/bin/$(TARGET)-gfortran \
                    $(PREFIX)/$(BUILD)/bin/$(PROCESSOR)-w64-mingw32-gfortran, \
        ln -sf '$(PREFIX)/$(BUILD)/bin/flang-target-wrapper.sh' $(EXEC);)

    $(foreach EXEC, ld objdump, \
        ln -sf '$(PREFIX)/$(TARGET)/bin/$(EXEC)-wrapper.sh' '$(PREFIX)/bin/$(TARGET)-$(EXEC)';)
endef

$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @mingw-crt-config-opts@,--disable-lib32 --enable-lib64,$($(PKG)_BUILD_mingw-w64))
$(PKG)_BUILD_i686-w64-mingw32   = $(subst @mingw-crt-config-opts@,--enable-lib32 --disable-lib64,$($(PKG)_BUILD_mingw-w64))
$(PKG)_BUILD_armv7-w64-mingw32   = $(subst @mingw-crt-config-opts@,--disable-lib32 --disable-lib64 --enable-libarm32,$($(PKG)_BUILD_mingw-w64))
$(PKG)_BUILD_aarch64-w64-mingw32 = $(subst @mingw-crt-config-opts@,--disable-lib32 --disable-lib64 --enable-libarm64,$($(PKG)_BUILD_mingw-w64))
