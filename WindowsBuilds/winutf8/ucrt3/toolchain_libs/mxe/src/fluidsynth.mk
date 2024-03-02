# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := fluidsynth
$(PKG)_WEBSITE  := http://fluidsynth.org/
$(PKG)_DESCR    := FluidSynth - a free software synthesizer based on the SoundFont 2 specifications
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.3.4
$(PKG)_CHECKSUM := 1529ef5bc3b9ef3adc2a7964505912f7305103e269e50cc0316f500b22053ac9
$(PKG)_GH_CONF  := FluidSynth/fluidsynth/tags,v
$(PKG)_DEPS     := cc dbus glib jack libsndfile mman-win32 portaudio readline

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(TARGET)-cmake' '$(SOURCE_DIR)' \
        -Denable-dbus=ON \
        -Denable-jack=$(CMAKE SHARED_BOOL) \
        -Denable-libsndfile=ON \
        -Denable-portaudio=ON \
        -Denable-readline=ON \
        $($(PKG)_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # fix pkg-config file
    $(SED) -i -e 's!/[^ ]*/libgomp\.a!-fopenmp!g' \
        -e 's!/[^ ]*/libomp\.dll\.a!-fopenmp!g' \
        -e 's!$(PREFIX)/$(TARGET)/lib/lib\([a-zA-Z0-9]\+\)\.a!-l\1!g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-fluidsynth.exe' \
        `'$(TARGET)-pkg-config' --cflags --libs fluidsynth`
endef
