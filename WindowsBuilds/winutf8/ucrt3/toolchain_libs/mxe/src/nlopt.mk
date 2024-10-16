# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := nlopt
$(PKG)_WEBSITE  := https://nlopt.readthedocs.io/en/latest/
$(PKG)_DESCR    := NLopt
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.8.0
$(PKG)_CHECKSUM := e02a4956a69d323775d79fdaec7ba7a23ed912c7d45e439bc933d991ea3193fd
$(PKG)_GH_CONF  := stevengj/nlopt/releases/tags,v
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DNLOPT_PYTHON=OFF \
        -DNLOPT_OCTAVE=OFF \
        -DNLOPT_MATLAB=OFF \
        -DNLOPT_GUILE=OFF \
        -DNLOPT_SWIG=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1
endef
