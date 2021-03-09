# This is a very ugly hack to build V8 library based on Msys2 Node.js
# package. The build of Node.js fails, but after providing static libraries
# for V8.

PKG             := libv8
$(PKG)_WEBSITE  := https://v8.dev/
$(PKG)_DESCR    := V8 Library (from Node.js)
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 11.15.0
$(PKG)_CHECKSUM := 68a776c5d8b8b91a8f2adac2ca4ce4390ae1804883ec7ec9c0d6a6a64d306a76
$(PKG)_SUBDIR   := node-v$($(PKG)_VERSION)
$(PKG)_FILE     := node-v$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://nodejs.org/dist/latest-v11.x/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

LIBV8_ENVVARS =  \
      CC=$(TARGET)-gcc CXX=$(TARGET)-g++ AR=$(TARGET)-ar \
      CC_target=$(TARGET)-gcc CXX_target=$(TARGET)-g++ AR_target=$(TARGET)-ar \
      CXX_host=g++ CC_host=gcc AR_host=ar \
      CXXFLAGS=-D_WIN32_WINNT=0x0601

define $(PKG)_BUILD
    # the patches only "work" for crosscompilation from Linux to Windows


    cd '$(1)' && env $(LIBV8_ENVVARS) ./configure \
      --cross-compiling \
      --dest-os=win \
      --dest-cpu=x86_64 \
      --without-intl \
      --without-etw \
      --openssl-no-asm \
      --without-snapshot

    cd '$(1)' && env $(LIBV8_ENVVARS) python2 tools/gyp_node.py -f make && touch config.gypi

    cd '$(1)' && env $(LIBV8_ENVVARS) $(MAKE) -C out BUILDTYPE=Release V=1 -j -k || \
                 $(LIBV8_ENVVARS) $(MAKE) -C out BUILDTYPE=Release V=1 -j 1 || \
                 env echo "build failures are expected, but libv8 should build"

      # -k is important, the build will fail, but after producing libv8
      # static libraries

    $(INSTALL) -d '$(PREFIX)'/$(TARGET)/lib
    $(INSTALL) -d '$(PREFIX)'/$(TARGET)/include
    $(INSTALL) -d '$(PREFIX)'/$(TARGET)/include/libplatform

    $(INSTALL) -m644 '$(1)'/deps/v8/include/*.h '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644 '$(1)'/deps/v8/include/libplatform/*.h \
                     '$(PREFIX)/$(TARGET)/include/libplatform'
    
    $(INSTALL) -m644 '$(1)'/out/Release/obj.target/deps/v8/gypfiles/libv8*.a \
                     '$(PREFIX)/$(TARGET)/lib'

    [ -f $(PREFIX)/$(TARGET)/lib/libv8_init.a ]

endef
