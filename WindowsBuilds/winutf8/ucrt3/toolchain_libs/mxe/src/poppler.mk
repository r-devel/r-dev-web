# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := poppler
$(PKG)_WEBSITE  := https://poppler.freedesktop.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 25.09.1
$(PKG)_CHECKSUM := 0c1091d01d3dd1664a13816861e812d02b29201e96665454b81b52d261fad658
$(PKG)_SUBDIR   := poppler-$($(PKG)_VERSION)
$(PKG)_FILE     := poppler-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://poppler.freedesktop.org/$($(PKG)_FILE)
$(PKG)_DEPS     := cc boost cairo curl freetype glib jpeg lcms libpng \
                   libwebp openjpeg tiff zlib poppler-data

define $(PKG)_UPDATE
    $(call GET_LATEST_VERSION, https://poppler.freedesktop.org/releases.html, poppler-)
endef

define $(PKG)_BUILD_COMMON
    cd '$(BUILD_DIR)' && $(TARGET)-cmake \
        -DPOPPLER_REQUIRES="lcms2 freetype2 libjpeg libpng libopenjp2 libtiff-4" \
        -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
        -DBUILD_GTK_TESTS=OFF \
        -DBUILD_QT5_TESTS=OFF \
        -DBUILD_QT6_TESTS=OFF \
        -DBUILD_CPP_TESTS=OFF \
        -DBUILD_MANUAL_TESTS=OFF \
        -DENABLE_SPLASH=ON \
        -DENABLE_UTILS=OFF \
        -DENABLE_CPP=@build_with_cpp@ \
        -DENABLE_GLIB=@build_with_glib@ \
        -DENABLE_GOBJECT_INTROSPECTION=OFF \
        -DENABLE_GPGME=OFF \
        -DENABLE_GTK_DOC=OFF \
        -DENABLE_NSS3=OFF \
        -DENABLE_QT5=@build_with_qt5@ \
        -DQt6Core_DIR='$(PREFIX)/$(TARGET)/qt6/lib/cmake/Qt6Core' \
        -DQt6Gui_DIR='$(PREFIX)/$(TARGET)/qt6/lib/cmake/Qt6Gui' \
        -DQt6Widgets_DIR='$(PREFIX)/$(TARGET)/qt6/lib/cmake/Qt6Widgets' \
        -DQt6Test_DIR='$(PREFIX)/$(TARGET)/qt6/lib/cmake/Qt6Test' \
        -DENABLE_QT6=@build_with_qt6@ \
        -DENABLE_LIBOPENJPEG=openjpeg2 \
        -DENABLE_CMS=lcms2 \
        -DENABLE_DCTDECODER=libjpeg \
        -DENABLE_LIBCURL=ON \
        -DENABLE_ZLIB=ON \
        -DENABLE_ZLIB_UNCOMPRESS=OFF \
        -DSPLASH_CMYK=ON \
        -DUSE_FIXEDPOINT=OFF \
        -DUSE_FLOAT=OFF \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DENABLE_RELOCATABLE=ON \
        -DEXTRA_WARN=OFF \
        -DFONT_CONFIGURATION=win32 \
        -DENABLE_NSS3=OFF \
        -DENABLE_GPGME=OFF \
        -DCMAKE_C_FLAGS='$(if $(BUILD_STATIC),-DCAIRO_WIN32_STATIC_BUILD,)' \
        -DCMAKE_CXX_FLAGS='$(if $(BUILD_STATIC),-DCAIRO_WIN32_STATIC_BUILD,)' \
        '$(SOURCE_DIR)'
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'

    $(if $(BUILD_STATIC), \
         if [ @build_with_glib@ == ON ] ; then \
             $(SED) -i -e 's/^\(Requires.private:.*\)/\1 gio-2.0/g' \
                   '$(BUILD_DIR)/poppler-glib.pc' ; \
         fi \
    )
endef

define $(PKG)_BUILD
    $(subst @build_with_cpp@,ON, \
    $(subst @build_with_glib@,ON, \
    $(subst @build_with_qt5@,OFF, \
    $(subst @build_with_qt6@,OFF, \
    $($(PKG)_BUILD_COMMON)))))
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic -std=c++11 \
        $(if $(MXE_IS_LLVM),-Wno-c++14-attribute-extensions) \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' poppler-cpp freetype2 libjpeg libtiff-4 libpng libopenjp2 --cflags --libs` -liconv
endef

