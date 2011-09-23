call d:\RCompile\CRANpkg\make\set_devel_Env.bat 
set Kurt=Kurt
d:
cd d:\Rcompile\CRANpkg\make
R -f check_diffs_send.R --vanilla --quiet --args R_default_packages=NULL > log\check_diffs_send.Rout 2>&1
exit
