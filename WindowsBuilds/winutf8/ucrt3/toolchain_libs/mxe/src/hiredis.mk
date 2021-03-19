
PKG             := hiredis
$(PKG)_WEBSITE  := https://github.com/redis/hiredis
$(PKG)_DESCR    := HIREDIS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.0
$(PKG)_CHECKSUM := 2a0b5fe5119ec973a0c1966bfc4bd7ed39dbce1cb6d749064af9121fe971936f
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
