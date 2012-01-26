#!/bin/sh

for i in `find /Library/Frameworks/R.framework -name R -type f -o -name \*.so -type f -o -name \*.dylib -type f|grep -v dSYM`; do
  if file "$i" | grep Mach-O >/dev/null; then
    # fix the ID so packages can be compiled
    if file "$i" | grep dynamic >/dev/null; then
      libid=`otool -L "$i" | grep '(comp' | sed 's: (comp.*::' | tr -d '\t' | sed 's:^/Library/Frameworks/:@rpath/:' | head -n 1`
      if test `basename "$libid"` = "$libid"; then
	  libid=`echo "$i" | sed 's:^/Library/Frameworks/:@rpath/:'`
      fi
      echo "$i -> $libid"
      install_name_tool -id "$libid" "$i"
    fi
    # fix all referenced libraries in R
    for l in `otool -L "$i" | grep R.framework/ | sed 's: (comp.*::' | sed 's:^ ::g'`; do
      install_name_tool -change "$l" "`echo $l|sed 's:.*R.framework/:@rpath/R.framework/:'`" "$i"
    done
  fi
done

