for p in ../contrib/*.tar.gz; do
  pkgname=`basename $p | sed  -e 's/_.*//'`
if test $p -nt $pkgname.in; then
  echo $pkgname
  rm -rf $pkgname
  tar zxf $p
  touch -r $p $pkgname.in
fi
done
for p in spatial; do
rm -rf $p
tar zxf ../2.14.0/Recommended/${p}_*
touch -r ../2.14.0/Recommended/${p}_* ${p}.in
done
