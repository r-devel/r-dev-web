call d:\RCompile\CRANpkg\make\set_recent_Env.bat 
d:
cd d:\Rcompile\CRANpkg\make
R -f check_diffs_send.R --vanilla --quiet --args R_default_packages=NULL > log\check_diffs_send.Rout 2>&1
exit
