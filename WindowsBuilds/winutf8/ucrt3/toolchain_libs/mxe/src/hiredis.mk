
PKG             := hiredis
$(PKG)_WEBSITE  := https://github.com/redis/hiredis
$(PKG)_DESCR    := HIREDIS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.2
$(PKG)_CHECKSUM := e0ab696e2f07deb4252dda45b703d09854e53b9703c7d52182ce5a22616c3819
$(PKG)_GH_CONF  := redis/hiredis/releases,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_URL      := https://github.com/redis/hiredis/archive/v$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc openssl

define $(PKG)_BUILD
   # Path from https://github.com/r-windows/rtools-packages/pull/162
   # but a trunk version of hiredis has a newer one
   mkdir '$(1)/.build'
   cd '$(1)/.build' && $(TARGET)-cmake \
           -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
           -DENABLE_SSL=ON \
           -DCMAKE_BUILD_TYPE="Release" \
           -DENABLE_EXAMPLES=OFF \
        '$(1)' 
   $(MAKE) -C '$(1)/.build' -j '$(JOBS)' 
   $(MAKE) -C '$(1)/.build' -j 1 install
endef
