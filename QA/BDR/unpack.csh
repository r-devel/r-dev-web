foreach p (../contrib/*.tar.gz)
set pkgname=`echo "${p}" | sed -e 's+^../contrib/++' -e 's/_.*//'`
echo $pkgname
tar zxf $p
touch -r $p $pkgname.in
end
