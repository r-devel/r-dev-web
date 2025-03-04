# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := opencv
$(PKG)_WEBSITE  := https://opencv.org/
$(PKG)_DESCR    := OpenCV
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.11.0
$(PKG)_CHECKSUM := 9a7c11f924eff5f8d8070e297b322ee68b9227e003fd600d4b8122198091665f
$(PKG)_GH_CONF  := opencv/opencv/releases
$(PKG)_DEPS     := cc eigen ffmpeg jasper jpeg libpng libwebp \
                   openblas openexr protobuf tiff xz zlib opencv-contrib

# -DCMAKE_CXX_STANDARD=98 required for non-posix gcc7 build

define $(PKG)_BUILD
    $(call PREPARE_PKG_SOURCE,opencv-contrib,$(BUILD_DIR))
    # build
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
      -DWITH_QT=OFF \
      -DWITH_OPENGL=ON \
      -DWITH_GSTREAMER=OFF \
      -DWITH_GTK=OFF \
      -DWITH_VIDEOINPUT=ON \
      -DWITH_XINE=OFF \
      -DWITH_LAPACK=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_PACKAGE=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_WITH_DEBUG_INFO=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_ZLIB=OFF \
      -DBUILD_TIFF=OFF \
      -DBUILD_JASPER=OFF \
      -DBUILD_JPEG=OFF \
      -DBUILD_WEBP=OFF \
      -DBUILD_PROTOBUF=OFF \
      -DPROTOBUF_UPDATE_FILES=ON \
      -DBUILD_PNG=OFF \
      -DBUILD_OPENEXR=OFF \
      -DCMAKE_VERBOSE=ON \
      -DOPENCV_GENERATE_PKGCONFIG=ON \
      -DOPENCV_EXTRA_MODULES_PATH='$(BUILD_DIR)/opencv_contrib-$($(PKG)_VERSION)/modules' \
      $(if $(MXE_IS_LLVM),-DWITH_OBSENSOR=OFF)

    # install
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    $(INSTALL) -m755 '$(BUILD_DIR)/unix-install/opencv4.pc' '$(PREFIX)/$(TARGET)/lib/pkgconfig'

    # fix pkg-config file
    echo 'Requires.private: libavdevice libtiff-4' \
        >> '$(PREFIX)/$(TARGET)/lib/pkgconfig/opencv4.pc'
    $(SED) -i -e 's/-lIconv::Iconv/-liconv/g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/opencv4.pc'

    # fix cmake file, avoid absolute paths to libraries
    $(SED) -i -e 's-\(/[^/;]\+\)\+/lib/lib\([[:alnum:]]\+\).a-\2-g' \
                 '$(PREFIX)/$(TARGET)/lib/cmake/opencv4/OpenCVModules.cmake'

    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -std=c++11 \
        '$(SOURCE_DIR)/samples/cpp/fback.cpp' -o '$(PREFIX)/$(TARGET)/bin/test-opencv.exe' \
        `'$(TARGET)-pkg-config' opencv4 --cflags --libs`
	#-lwebp
endef
