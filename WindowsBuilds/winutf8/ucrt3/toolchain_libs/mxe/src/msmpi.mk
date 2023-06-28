# Uses msys2 package mingw-w64-msmpi to extract the redistributable
# Microsoft MPI SDK

PKG             := msmpi
$(PKG)_WEBSITE  := https://docs.microsoft.com/en-us/message-passing-interface/microsoft-mpi
$(PKG)_DESCR    := Microsoft MPI SDK 10.1.1
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 72e0ee2
$(PKG)_CHECKSUM := ff0a2983f0ca2ad6180b8d8ad9eff914d6b8361dfb7f9c8645ebfff27e30b1ea
$(PKG)_GH_CONF  := msys2/MINGW-packages/branches/master
$(PKG)_DEPS     := cc fc

define $(PKG)_BUILD
    # Create import library libmsmpi.a
    mkdir -p '$(BUILD_DIR)/lib'
    $(TARGET)-dlltool -k -d \
        '$(SOURCE_DIR)/mingw-w64-msmpi/msmpi.def.$(if $(findstring x86_64,$(TARGET)),x86_64,i686)' \
         -l '$(BUILD_DIR)/lib/libmsmpi.a'

    # Create Fortran 90 modules
    mkdir -p '$(BUILD_DIR)/f90'
    cd '$(BUILD_DIR)/f90' && \
        cp '$(SOURCE_DIR)/mingw-w64-msmpi/mpifptr.h.$(if $(findstring x86_64,$(TARGET)),x86_64,i686)' \
           ./mpifptr.h && \
        $(TARGET)-gfortran -fallow-invalid-boz -fallow-argument-mismatch -J.\
                           -c '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.f90'

    # Create compiler wrappers
    mkdir -p '$(BUILD_DIR)/bin'
    $(TARGET)-gcc -DCC -c '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.c' -o '$(BUILD_DIR)/bin/mpicc.exe'
    $(TARGET)-gcc -DCXX -c '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.c' -o '$(BUILD_DIR)/bin/mpicxx.exe'
    $(TARGET)-gcc -DFC -c '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.c' -o '$(BUILD_DIR)/bin/mpif90.exe'
    $(TARGET)-gcc -DFC -c '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.c' -o '$(BUILD_DIR)/bin/mpif77.exe'

        
    $(INSTALL) -m644  '$(BUILD_DIR)/lib/libmsmpi.a' '$(PREFIX)/$(TARGET)/lib'

    $(INSTALL) -m644  '$(BUILD_DIR)/f90/mpi_constants.mod' '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644  '$(BUILD_DIR)/f90/mpi_sizeofs.mod' '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644  '$(BUILD_DIR)/f90/mpi_base.mod' '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644  '$(BUILD_DIR)/f90/mpi.mod' '$(PREFIX)/$(TARGET)/include'

    $(INSTALL) -m644  '$(BUILD_DIR)/bin/mpicc.exe' '$(PREFIX)/$(TARGET)/bin'
    $(INSTALL) -m644  '$(BUILD_DIR)/bin/mpicxx.exe' '$(PREFIX)/$(TARGET)/bin'
    $(INSTALL) -m644  '$(BUILD_DIR)/bin/mpif90.exe' '$(PREFIX)/$(TARGET)/bin'
    $(INSTALL) -m644  '$(BUILD_DIR)/bin/mpif77.exe' '$(PREFIX)/$(TARGET)/bin'

    $(INSTALL) -m644  '$(SOURCE_DIR)/mingw-w64-msmpi/mpi.h' '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644  '$(SOURCE_DIR)/mingw-w64-msmpi/mpif.h' '$(PREFIX)/$(TARGET)/include'
    $(INSTALL) -m644  '$(BUILD_DIR)/f90/mpifptr.h' '$(PREFIX)/$(TARGET)/include'
endef
