ifeq ($(R_TARGET),aarch64)
  MXE_PLUGIN_DIRS += plugins/llvm-mingw plugins/llvm-mingw/host-toolchain
  MXE_TARGETS := aarch64-w64-mingw32.static.posix
  LOCAL_BASE_PKG_LIST := llvm-mingw llvm-mingw-host
  MXE_IS_LLVM := $(true)
else
  MXE_PLUGIN_DIRS += plugins/gcc13
  MXE_TARGETS := x86_64-w64-mingw32.static.posix
  LOCAL_BASE_PKG_LIST := gcc gcc-host
  LOCAL_FULL_PKG_LIST += binutils yasm nasm msmpi
  MXE_IS_LLVM := $(false)
endif

# for cmake-host
MXE_PLUGIN_DIRS += plugins/examples/host-toolchain

#  --- base toolchain, plus libraries for base and recommended R packages ---

# tcl tk tktable not included (built separately as Tcl/Tk bundle, for
# historical reasons)

LOCAL_BASE_PKG_LIST += bzip2 cairo curl fontconfig freetype icu4c jpeg libpng ncurses openssl pcre2 pixman readline tiff xz zlib librtmp zstd pkgconf-host libdeflate dlfcn-win32

#  --- libraries for other contributed R packages, development tools ---

LOCAL_FULL_PKG_LIST += boost cfitsio cmake expat ffmpeg fftw gdal geos gettext giflib glpk gmp gpgme gsl harfbuzz hdf4 hdf5 isl jasper jsoncpp lame lapack libarchive libassuan libffi libgeotiff libgit2 libiconv libsndfile libssh libssh2 libtool libuv libvpx libwebp libxml2 lz4 mpc mpfr netcdf nettle nlopt openblas opencv pcre poppler proj protobuf tcl termcap x264 xvidcore intel-tbb json-c
LOCAL_FULL_PKG_LIST += freexl gpgme ogg spatialite tre vorbis yaml-cpp jsoncpp lzo openjpeg pkgconf sqlite libgit2
LOCAL_FULL_PKG_LIST += imagemagick librsvg libmysqlclient sox libzmq libidn fluidsynth

#  --- libraries for other contributed R packages, development tools, added for R ---
LOCAL_FULL_PKG_LIST += udunits redland coinor-symphony libsbml jq libmariadbclient hiredis
LOCAL_FULL_PKG_LIST += grpc flint

# --- additional tools
LOCAL_FULL_PKG_LIST += cmake-host tidy-html5

ifeq ($(R_TOOLCHAIN_TYPE),base)
    $(info Building base R toolchain)
    LOCAL_PKG_LIST := $(LOCAL_BASE_PKG_LIST)
else
    $(info Building full R toolchain)
    LOCAL_PKG_LIST := $(LOCAL_BASE_PKG_LIST) $(LOCAL_FULL_PKG_LIST)
endif

.DEFAULT_GOAL  := local-pkg-list
local-pkg-list: $(LOCAL_PKG_LIST)
