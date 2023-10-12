
PKG             := libmariadbclient
$(PKG)_WEBSITE  := https://mariadb.org/
$(PKG)_DESCR    := MariaDB Client
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.2.7
$(PKG)_CHECKSUM := 9d7196248e6697c09c73e173fe9b282045f55ec9d7ae743c1ebad08b9ea56dda
$(PKG)_SUBDIR   := mariadb-connector-c-$($(PKG)_VERSION)-src
$(PKG)_FILE     := mariadb-connector-c-$($(PKG)_VERSION)-src.tar.gz
#$(PKG)_URL      := https://downloads.mariadb.org/interstitial/connector-c-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL      := https://mirror.vpsfree.cz/mariadb/connector-c-$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc zlib curl

define $(PKG)_BUILD
    mkdir '$(1)/.build'
    cd '$(1)/.build' && $(TARGET)-cmake \
            -DBUILD_SHARED=$(CMAKE_SHARED_BOOL) \
            -DBUILD_STATIC=$(CMAKE_STATIC_BOOL) \
            -DCMAKE_BUILD_TYPE="Release" \
            -DWITH_EXTERNAL_ZLIB=ON \
            -DWITH_MYSQLCOMPAT=OFF \
            -DWITH_SSL="SCHANNEL" \
            -DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT=STATIC \
            -DCLIENT_PLUGIN_DIALOG=STATIC \
            -DCLIENT_PLUGIN_REMOTE_IO=OFF \
            -DCLIENT_PLUGIN_PVIO_NPIPE=STATIC \
            -DCLIENT_PLUGIN_PVIO_SHMEM=STATIC \
            -DCLIENT_PLUGIN_CLIENT_ED25519=OFF \
            -DCLIENT_PLUGIN_CACHING_SHA2_PASSWORD=STATIC \
            -DCLIENT_PLUGIN_SHA256_PASSWORD=STATIC \
            -DCLIENT_PLUGIN_MYSQL_CLEAR_PASSWORD=STATIC \
            -DCLIENT_PLUGIN_MYSQL_OLD_PASSWORD=STATIC \
            -DCMAKE_C_FLAGS='-D_WIN32_WINNT=0x0601' \
        '$(1)'

    $(MAKE) -C '$(1)/.build' -j '$(JOBS)' 
    $(MAKE) -C '$(1)/.build' -j 1 install

    rm -f '$(PREFIX)/$(TARGET)'/lib/mariadb/libmariadb.dll
    rm -f '$(PREFIX)/$(TARGET)'/lib/mariadb/libmariadb.dll.a
    mv -f '$(PREFIX)/$(TARGET)'/lib/mariadb/libmariadbclient.a '$(PREFIX)/$(TARGET)'/lib

    # create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'prefix=$(PREFIX)/$(TARGET)'; \
     echo 'includedir=$${prefix}/include'; \
     echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $($(PKG)_DESCR)'; \
     echo 'Libs: -lmariadbclient'; \
     echo 'Requires.private: cfitsio zlib'; \
     echo 'Libs.private: -lsspicli -lsecurity -lsecur32 -lschannel -ldigest -lcfitsio -lncrypt -lksecdd -lcrypt32 -lbcrypt -lwsock32 -lws2_32 -lshlwapi'; \
     echo 'Cflags: -I$${includedir}/mariadb' \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

endef
