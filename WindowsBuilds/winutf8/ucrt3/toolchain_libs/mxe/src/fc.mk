# This file is part of MXE. See LICENSE.md for licensing information.

# This meta-package for fortran compilation ensures that the fortran runtime
# libraries are available for cross-compilation (they are created as a part
# of building the host native toolchain). This is only needed for flang
# (LLVM).

PKG             := fc
$(PKG)_WEBSITE  := https://mxe.cc/
$(PKG)_DESCR    := Dependency package for cross libraries (Fortran)
$(PKG)_VERSION  := 1
$(PKG)_DEPS     := $(if $(MXE_IS_LLVM),llvm-mingw-host,gcc)
$(PKG)_OO_DEPS   = pkgconf
$(PKG)_TYPE     := meta
$(PKG)_DEPS_$(BUILD) :=
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
