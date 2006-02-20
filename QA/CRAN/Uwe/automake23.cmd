set Path=.;d:\compiler\gcc\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;D:\compiler\texmf\miktex\bin;d:\compiler\htmlhelp;d:\compiler\perl\bin;e:\software\putty;C:\Programme\gstools\gs8.14\bin;d:\Rcompile\recent\R\bin

set LC_ALL=C
set R_LIBS=d:/Rcompile/CRANpkg/lib/2.3
set TMPDIR=d:\temp
set _R_CHECK_FORCE_SUGGESTS_=FALSE

set HDF5=d:/Compiler/gcc/lib
set LIB_XML=d:/Compiler/gcc
set GDWIN32=d:/Rcompile/CRANpkg/extralibs/gdwin32
set QUANTLIB_ROOT=d:/Rcompile/CRANpkg/extralibs/QuantLib

d:
cd d:\Rcompile\CRANpkg\make
set maj.version=2.3
R CMD BATCH Auto-Pakete.R Auto-Pakete23.Rout
exit
