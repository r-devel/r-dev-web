#!/bin/bash
#
# aux.sh [--force] 

: ${BASE=/Volumes/Builds/R4}

PKGROOT="$BASE/packaging"

cd "$PKGROOT"

. $BASE/unlock-sign
. $BASE/common

if [ $ARCH = x86_64 ]; then
: ${PACKAGES="texinfo-6.7 tcltk-8.6:8.6.6"}
else    
: ${PACKAGES="texinfo-6.8 tcltk-8.6:8.6.12"}
fi

for pkg in $PACKAGES; do
    name=`echo $pkg | sed 's:-.*::'`
    dir=`echo $pkg | sed 's/:.*//'`
    ver=`echo $pkg | sed 's:.*-::' | sed 's/.*://'`
    echo ''
    echo "--- Packaging $name in $dir, version $ver ..."
    echo ''

    if [ ! -e $PKGROOT/$dir/usr -a ! -e $PKGROOT/$dir/opt ]; then
	echo "*** ERROR: missing $PKGROOT/$dir/"'(usr|opt)' >&2
	exit 1
    fi
    if [ ! -e "$PKGROOT/$name.plist" ]; then
	echo "*** ERROR: missing $PKGROOT/$name.plist" >&2
	echo " (you can use pkgbuild --analyze --root $dir $name.plist to create a template)"
	exit 1
    fi
    if [ -z "$NOSIGN" ]; then
	echo " - signing contents of $dir"
	$PKGROOT/R-sign-contents "$dir" "$1"
    fi

    echo " - building $name.pkg from $dir ..."
    if pkgbuild --sign 'Developer ID Installer' --identifier org.r-project.$ARCH.$name --install-location / --version "$ver" --timestamp --root "$dir" --component-plist "$name.plist" "$name.pkg"; then
	echo "   OK"
	ls -l "$name.pkg"
    else
	echo "*** ERROR: failed: pkgbuild --sign 'Developer ID Installer' --identifier org.r-project.$ARCH.$name --install-location / --version $ver --timestamp --root $dir --component-plist $name.plist $name.pkg"
	exit 1
    fi
done
