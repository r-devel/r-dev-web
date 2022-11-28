#!/usr/bin/env bash

# rtools support pkgs (toolchains below)
# Potential risk of PATH conflicts: curl, perl (via texinfo texinfo-tex), gpg
_rtools_msys_pkgs="rsync winpty file bsdtar findutils libxml2 libexpat mintty msys2-launcher pacman curl make tar texinfo texinfo-tex patch diffutils gawk grep rebase zip unzip gzip"

_thisdir="$(dirname $0)"
test "${_thisdir}" = "." && _thisdir=${PWD}

_arch=$(uname -m)
_date=$(date +'%Y%m%d')
_version=${_date}
_filename2=rtools-${_arch}-${_date}.tar.xz

_newmsysbase="${_thisdir}/build"
_newbasename="rtools43"
_newmsys="${_newmsysbase}/${_newbasename}"
_log="${_thisdir}/installer-${_arch}-${_date}.log"

create_chroot_system() {
  [ -d ${_newmsysbase} ] && rm -rf ${_newmsysbase}
  mkdir -p "${_newmsys}"
  pushd "${_newmsys}" > /dev/null

    mkdir -p var/lib/pacman
    mkdir -p var/log
    mkdir -p tmp

    eval "pacman -Syu --root \"${_newmsys}\"" | tee -a ${_log}
    eval "pacman -Sy ${_rtools_msys_pkgs} --noconfirm --root \"${_newmsys}\"" | tee -a ${_log}
    _result=$?
    if [ "${_result}" -ne "0" ]; then
      echo "failed to create msys2 chroot in ${_newmsys}"
      exit 1
    fi

    # Remove cache files that need to be created by user
    eval "pacman -Sycc --noconfirm --root \"${_newmsys}\""
    rm -Rf "${_newmsys}/var/lib/pacman/sync"

    # Change user home directory to match Windows
    echo "Patching nsswitch.conf"
    sed -i 's/db_home: cygwin/db_home: windows #cygwin/' ./etc/nsswitch.conf
    echo "OK:"
    cat ./etc/nsswitch.conf

    # Adding scripts to user profile
    echo "Copy aliases.sh gitbin.sh"
    cp "${_thisdir}/aliases.sh" ./etc/profile.d/
    cp "${_thisdir}/gitbin.sh" ./etc/profile.d/

  popd > /dev/null
}

rm -f "${_log}"
echo "Creating MSYS2 chroot system ${_newmsys}" | tee -a ${_log}
create_chroot_system

# Test that it worked
if [ -f "${_newmsys}/usr/bin/make.exe" ]; then
  echo "Success!"
  exit 0
else
  echo "Failed to install rtools in chroot :("
  exit 1
fi
