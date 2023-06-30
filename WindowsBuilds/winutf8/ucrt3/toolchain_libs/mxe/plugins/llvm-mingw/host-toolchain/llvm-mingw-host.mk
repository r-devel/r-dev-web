# This file is part of MXE. See LICENSE.md for licensing information.
# based on https://github.com/mstorsjo/llvm-mingw

PKG             := llvm-mingw-host
$(PKG)_WEBSITE  := $(llvm-mingw_WEBSITE)
$(PKG)_DESCR    := $(llvm-mingw_DESCR)
$(PKG)_IGNORE   := $(llvm-mingw_IGNORE)
$(PKG)_VERSION  := $(llvm-mingw_VERSION)
$(PKG)_CHECKSUM := $(llvm-mingw_CHECKSUM)
$(PKG)_PATCHES  := $(llvm-mingw_PATCHES)
$(PKG)_GH_CONF  := $(llvm-mingw_GH_CONF)
$(PKG)_SUBDIR   := $(llvm-mingw_SUBDIR)
$(PKG)_FILE     := $(llvm-mingw_FILE)
$(PKG)_URL      := $(llvm-mingw_URL)
$(PKG)_DEPS     := llvm-host llvm-mingw

define $(PKG)_UPDATE
    echo $(llvm-mingw_VERSION)
endef

define $(PKG)_BUILD
    $(eval LLVM_MAJOR := $(shell echo $(llvm_VERSION) | cut -d . -f1))

    # clang-target-wrapper calls to clang-16, which is produced by the build
    # (and originally named clang)

    [ -f '$(PREFIX)/$(TARGET)/bin/clang-$(LLVM_MAJOR).exe' ] || \
        mv '$(PREFIX)/$(TARGET)/bin/clang.exe' \
        '$(PREFIX)/$(TARGET)/bin/clang-$(LLVM_MAJOR).exe'

    # flang produced by the build calls into aarch64-w64-mingw32-flang,
    # unless it has that name; so we rename flang to that name, and
    # flang-target-wrapper calls it; consequently, this is inconsistent with
    # clang (the aarch64-w64-mingw32-clang version is a wrapper, but -flang
    # version is not); also, aarch64-w64-mingw32-flang cannot be used
    # directly without passing special arguments to it

    [ -f '$(PREFIX)/$(TARGET)/bin/$(PROCESSOR)-w64-mingw32-flang.exe' ] || \
        mv '$(PREFIX)/$(TARGET)/bin/flang.exe' \
        '$(PREFIX)/$(TARGET)/bin/$(PROCESSOR)-w64-mingw32-flang.exe'

    # always use the default target, because LLVM requires the short version
    # (detection of the long version in the wrapper is fixed below)

    $(SED) -i -e 's|if (!target)|/* if (!target) */|' \
                 '$(SOURCE_DIR)/wrappers/clang-target-wrapper.c'

    # always use pthread (macros, linking), to match the usual gcc behavior
    $(SED) -i -e 's|exec_argv\[arg++\] = _T("-fuse-ld=lld");|\0 exec_argv[arg++] = _T("-pthread");|' \
                 '$(SOURCE_DIR)/wrappers/clang-target-wrapper.c'

    # fix detection of the long target to correctly detect the executable,
    # and hence adjust the driver/standard for C

    $(SED) -i -e 's|TCHAR *period = _tcschr(basename, '.');|TCHAR *period = _tcsrchr(basename, '.');|' \
                 '$(SOURCE_DIR)/wrappers/native-wrapper.h'

    $(foreach WRAPPER, llvm-wrapper clang-target-wrapper, \
        cd '$(BUILD_DIR)' && \
        $(TARGET)-clang '-DDEFAULT_TARGET="$(PROCESSOR)-w64-mingw32"' \
                        '-DCLANG="clang-$(LLVM_MAJOR)"' \
                        -o '$(WRAPPER).exe' -I'$(SOURCE_DIR)/wrappers' \
                        '$(SOURCE_DIR)/wrappers/$(WRAPPER).c' && \
        $(INSTALL) -m755 '$(WRAPPER).exe' '$(PREFIX)/$(TARGET)/bin';)

    cd '$(BUILD_DIR)' && \
        $(TARGET)-clang '-DDEFAULT_TARGET="$(PROCESSOR)-w64-mingw32"' \
                        '-DCLANG="$(PROCESSOR)-w64-mingw32-flang"' \
                        -o 'flang-target-wrapper.exe' -I'$(SOURCE_DIR)/wrappers' \
                        '$(SOURCE_DIR)/wrappers/clang-target-wrapper.c' && \
        $(INSTALL) -m755 'flang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin'

    $(foreach EXEC, clang clang++ gcc g++ c++, \
        ln -sf '$(PREFIX)/$(TARGET)/bin/clang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(TARGET)-$(EXEC).exe'; \
        ln -sf '$(PREFIX)/$(TARGET)/bin/clang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(PROCESSOR)-w64-mingw32-$(EXEC).exe'; \
        ln -sf '$(PREFIX)/$(TARGET)/bin/clang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(EXEC).exe';)

    ln -sf '$(PREFIX)/$(TARGET)/bin/flang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(TARGET)-flang.exe'
    ln -sf '$(PREFIX)/$(TARGET)/bin/flang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/flang.exe'
    ln -sf '$(PREFIX)/$(TARGET)/bin/flang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(TARGET)-gfortran.exe'
    ln -sf '$(PREFIX)/$(TARGET)/bin/flang-target-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/gfortran.exe'

    $(foreach EXEC, addr2line ar ranlib nm objcopy strings strip, \
        ln -sf '$(PREFIX)/$(TARGET)/bin/llvm-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(TARGET)-$(EXEC).exe'; \
        ln -sf '$(PREFIX)/$(TARGET)/bin/llvm-wrapper.exe' '$(PREFIX)/$(TARGET)/bin/$(EXEC).exe';)

    ## comments in original llvm-mings, install-wrappers.sh say that windres
    ## and dlltool don't work with llvm-wrapper

    $(foreach EXEC, windres dlltool, \
        ln -sf '$(PREFIX)/$(TARGET)/bin/llvm-$(EXEC).exe' '$(PREFIX)/$(TARGET)/bin/$(TARGET)-$(EXEC).exe'; \
        ln -sf '$(PREFIX)/$(TARGET)/bin/llvm-$(EXEC).exe' '$(PREFIX)/$(TARGET)/bin/$(EXEC).exe';)

    ## it would be nicer to have an .exe wrapper, which could work outside
    ## msys

    $(foreach EXEC, ld objdump, \
        $(SED) -i -e 's|^DEFAULT_TARGET=.*|DEFAULT_TARGET=$(PROCESSOR)-w64-mingw32|' \
               '$(SOURCE_DIR)/wrappers/$(EXEC)-wrapper.sh'; \
        $(INSTALL) -m755 '$(SOURCE_DIR)/wrappers/$(EXEC)-wrapper.sh' '$(PREFIX)/$(TARGET)/bin';\
        ln -sf '$(PREFIX)/$(TARGET)/bin/$(EXEC)-wrapper.sh' \
               '$(PREFIX)/$(TARGET)/bin/$(TARGET)-$(EXEC)';)
endef
