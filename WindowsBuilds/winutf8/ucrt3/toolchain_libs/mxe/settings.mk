# plugins/tcl.tk
MXE_PLUGIN_DIRS += plugins/examples/host-toolchain plugins/gcc10

#MXE_TARGETS := x86_64-w64-mingw32.static.posix i686-w64-mingw32.static.posix
MXE_TARGETS := x86_64-w64-mingw32.static.posix

#  --- base toolchain, plus libraries for base and recommended R packages ---

# tcl tk tktable
LOCAL_PKG_LIST := bzip2 cairo curl fontconfig freetype gcc icu4c jpeg libpng ncurses openssl pcre2 pixman readline tiff xz zlib librtmp
LOCAL_PKG_LIST += gcc-host

#  --- libraries for other contributed R packages, development tools ---

LOCAL_PKG_LIST += binutils boost cfitsio cmake expat ffmpeg fftw gdal gdb geos gettext giflib glpk gmp gpgme gsl harfbuzz hdf4 hdf5 isl jasper jsoncpp lame lapack libarchive libassuan libffi libgeotiff libgit2 libiconv libsndfile libssh libssh2 libtool libuv libvpx libwebp libxml2 lz4 mpc mpfr nasm netcdf nettle nlopt openblas opencv pcre poppler proj protobuf tcl termcap x264 xvidcore yasm zstd intel-tbb json-c
LOCAL_PKG_LIST += freexl gpgme ogg spatialite tre vorbis yaml-cpp jsoncpp lzo openjpeg pkgconf sqlite libgit2
LOCAL_PKG_LIST += imagemagick librsvg libmysqlclient sox gtk2 libzmq msmpi

  # added for R
LOCAL_PKG_LIST += udunits redland coinor-symphony libsbml jq


.DEFAULT_GOAL  := local-pkg-list
local-pkg-list: $(LOCAL_PKG_LIST)
