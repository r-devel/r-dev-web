#!/bin/bash

: ${BASE=/Volumes/Builds/R4}

PKGROOT="$BASE/packaging"
if [ ! -e "$PKGROOT/R-app.plist" ]; then
    echo "ERROR: invalid BASE ($BASE), $PKGROOT/R-app.plist is missing" >&2
    exit 1
fi

## for oscode, ARCH
. $BASE/common

if [ -z "$TEMPLATE" ]; then
   TEMPLATE=template-$oscode-$ARCH
   if [ ! -e "$PKGROOT/$TEMPLATE" ]; then
       TEMPLATE=template-$oscode
       if [ ! -e "$PKGROOT/$TEMPLATE" ]; then
	   TEMPLATE=template
       fi
   fi
fi

osname=$oscode

NAME="$1"
if [ -z "$1" ]; then
    echo "Build name missing"
    exit 1;
fi

## arch prefix for IDs in packaging - only set on arm64
## since we did not use any prefix previously
if [ "$oscode" = big-sur ]; then
    XARCH=".$ARCH"
fi

echo "Packaging $NAME $oscode-$ARCH build, using $TEMPLATE"
export TEMPLATE

ngui=`ls $BASE/deploy/$osname/$NAME/R-GUI-*-$oscode-$ARCH-Release.tar.gz | wc -l | awk '{print $0 + 0}'`
if [ "$ngui" != 1 ]; then
    if [ "$ngui" = 0 ]; then
	echo "*** ERROR: R.app build is missing in $BASE/deploy/$osname/$NAME/R-GUI-*-$oscode-$ARCH-Release.tar.gz" >&2
    else
	echo "*** ERROR: more than one R.app tar balls in $BASE/deploy/$osname/$NAME/R-GUI-*-$oscode-$ARCH-Release.tar.gz" >&2
    fi
    exit 1
fi

Rapp=`ls $BASE/deploy/$osname/$NAME/R-GUI-*-$oscode-$ARCH-Release.tar.gz`
if [ -z "$Rapp" ]; then
    echo "*** ERROR: Missing R.app tar ball in $BASE/deploy/$osname/$NAME/R-GUI*Release.tar.gz" >&2
    exit 1
fi

FWTAR="$BASE/deploy/$osname/$NAME/$ARCH/$NAME.tar.gz"
if [ ! -e "$FWTAR" ]; then
    echo "*** ERROR: R framework build is missing in $FWTAR" >&1
    exit 1
fi

DST="$PKGROOT/dst"

echo " - Removing previous builds ..."
rm -rf "$DST/R-fw" "$DST/R-app"
mkdir "$DST/R-fw" "$DST/R-app"
rm -f "$PKGROOT/R-app.pkg" "$PKGROOT/R-fw.pkg" "$PKGROOT/R.pkg"

echo " - Extracting R.app ..."
tar fxz "$Rapp" -C "$DST/R-app"

. "$BASE/unlock-sign"

echo " - Signing R.app ..."
"$PKGROOT/R-sign-contents" "$DST/R-app" --force
## after signing inside contents we also have to re-sign the entire app bundle
codesign --force -o runtime --timestamp --entitlements "$BASE/R.entitlements" -s "Developer ID Application" "$DST/R-app/R.app"

echo " - Checking R.app signature ..."
if codesign -v "$DST/R-app/R.app"; then
    echo "   OK"
else
    echo "** ERROR: $DST/R-app/R.app does not pass codesign validation" >&1
    exit 1
fi

echo " - Extracting R framework ..."
tar fxz "$FWTAR" -C "$DST/R-fw"
mv "$DST/R-fw/Library/Frameworks/R.framework" "$DST/R-fw/"
rm -rf "$DST/R-fw/Library"

echo " - Signing R framework ..."
"$PKGROOT/R-sign-contents" "$DST/R-fw"

GUIVER=`sed -n 's:.*<string>R .*GUI ::p' "$DST/R-app/R.app/Contents/Info.plist" | sed 's:[- ].*::' | head -n1`
if [ -z "$GUIVER" ]; then
    echo "*** ERROR: cannot determine R-GUI version from $DST/R-app/R.app/Contents/Info.plist" >&2
    exit 1
fi    
export GUIVER
echo "   Detected GUI version $GUIVER"

echo " - Building R.app package ..."
echo pkgbuild --sign 'Developer ID Installer' --identifier org.R-project${XARCH}.R.GUI.pkg --install-location /Applications --version "$GUIVER" --timestamp --root "$DST/R-app" --component-plist "$PKGROOT/R-app.plist" "$PKGROOT/R-app.pkg"
pkgbuild --sign 'Developer ID Installer' --identifier org.R-project${XARCH}.R.GUI.pkg --install-location /Applications --version "$GUIVER" --timestamp --root "$DST/R-app" --component-plist "$PKGROOT/R-app.plist" "$PKGROOT/R-app.pkg"

RVER0=`sed -n 's:.*R_MAJOR::p' < "$DST/R-fw/R.framework/Headers/Rversion.h" | sed 's:[^0-9.]*::g'`
RVER1=`sed -n 's:.*R_MINOR::p' < "$DST/R-fw/R.framework/Headers/Rversion.h" | sed 's:[^0-9.]*::g'`
RSVN=`sed -n 's:.*R_SVN_REVISION::p' < "$DST/R-fw/R.framework/Headers/Rversion.h" | sed 's:[^0-9.]*::g'`
RSTAT=`sed -n 's:.*R_STATUS *"::p' < "$DST/R-fw/R.framework/Headers/Rversion.h" | sed 's:"*::g'`
if [ -z "$RSTAT" ]; then RSTAT=`sed -n 's:.*R_NICK *"::p' < "$DST/R-fw/R.framework/Headers/Rversion.h" | sed 's:"*::g'`; fi
VER="${RVER0}.${RVER1}"
export VER
VERFULL="$VER ($RSTAT)"
export VERFULL
export RSVN
if [ -z "$RVER0" -o -z "$RVER1" ]; then
    echo "*** ERROR: cannot determine R version from $DST/R-fw/R.framework/Headers/Rversion.h" >&2
    exit 1
fi

echo " - Building R framework package for $VERFULL ..."
echo pkgbuild --sign 'Developer ID Installer' --identifier org.R-project${XARCH}.R.fw.pkg --install-location /Library/Frameworks --version "$VER" --scripts "$PKGROOT/scripts-R-fw" --timestamp --root "$DST/R-fw" --component-plist "$PKGROOT/R-fw.plist" "$PKGROOT/R-fw.pkg"
pkgbuild --sign 'Developer ID Installer' --identifier org.R-project${XARCH}.R.fw.pkg --install-location /Library/Frameworks --version "$VER" --scripts "$PKGROOT/scripts-R-fw" --timestamp --root "$DST/R-fw" --component-plist "$PKGROOT/R-fw.plist" "$PKGROOT/R-fw.pkg"

echo " - Creating distribution description ..."
"$PKGROOT/mkres" "$PKGROOT"

## need to find xz for re-compression ...
for dir in /opt/R/`uname -m` /usr/local; do
    if [ -e $dir/bin/xz ]; then
	export PATH=$PATH:$dir/bin
	break
    fi
done

if [ ! -e "$BASE/deploy/$TNAME/$NAME" ]; then mkdir -p "$BASE/deploy/$TNAME/$NAME"; fi
if [ ! -e "$BASE/deploy/$TNAME/last-success" ]; then mkdir -p "$BASE/deploy/$TNAME/last-success"; fi

echo " - Building final bundle and last-success compression ..."
productbuild --timestamp --product "$PKGROOT/req.plist" --resources "$PKGROOT/res" --sign 'Developer ID Installer' --distribution "$PKGROOT/dist.plist" --package-path "$PKGROOT" "$PKGROOT/$NAME.pkg" && cp -p "$PKGROOT/$NAME.pkg" "$BASE/deploy/$TNAME/$NAME/" && echo "R $VERFULL, GUI $GUIVER in $NAME.pkg" > "$BASE/deploy/$TNAME/$NAME/$NAME.pkg.SUCCESS" && echo "SUCCESS, a copy is in $BASE/deploy/$TNAME/$NAME/$NAME.pkg" && cp -p "$PKGROOT/$NAME.pkg" "$BASE/deploy/$TNAME/last-success/${NAME}-${ARCH}.pkg" && tar fc - -C "$DST/R-fw" --uid 0 --gid 0 R.framework | xz -c9 > "$BASE/deploy/$TNAME/last-success/${NAME}-${ARCH}.tar.xz"
