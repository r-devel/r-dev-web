# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libvpx
$(PKG)_WEBSITE  := https://www.webmproject.org/code/
$(PKG)_DESCR    := vpx
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.14.1
$(PKG)_CHECKSUM := 901747254d80a7937c933d03bd7c5d41e8e6c883e0665fadcb172542167c7977
$(PKG)_GH_CONF  := webmproject/libvpx/tags,v
$(PKG)_DEPS     := cc pthreads \
                   $(if $(findstring x86_64, $(TARGET)), yasm, \
                       $(if $(findstring i686, $(TARGET)), yasm ))

# --extra-cflags='-std=gnu89'
define $(PKG)_BUILD
    $(SED) -i 's,yasm[ $$],$(TARGET)-yasm ,g' '$(1)/build/make/configure.sh'
    cd '$(1)' && \
        CROSS='$(TARGET)-' \
        ./configure \
        --prefix='$(PREFIX)/$(TARGET)' \
        --target=@libvpx-target@ \
        --disable-examples \
        --disable-install-docs \
        $(if $(findstring x86_64, $(TARGET)), --as=$(TARGET)-yasm, \
            $(if $(findstring i686, $(TARGET)), --as=$(TARGET)-yasm )) \
        $(if $(findstring aarch64,$(TARGET)),--disable-runtime-cpu-detect)
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
    $(TARGET)-ranlib $(PREFIX)/$(TARGET)/lib/libvpx.a
endef

$(PKG)_BUILD_i686-w64-mingw32   = $(subst @libvpx-target@,x86-win32-gcc,$($(PKG)_BUILD))
$(PKG)_BUILD_x86_64-w64-mingw32 = $(subst @libvpx-target@,x86_64-win64-gcc,$($(PKG)_BUILD))
$(PKG)_BUILD_aarch64-w64-mingw32 = $(subst @libvpx-target@,arm64-win64-gcc,$($(PKG)_BUILD))
