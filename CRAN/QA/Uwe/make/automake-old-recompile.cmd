call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_oldrelease_Env.bat 
set mailMaintainer=no

d:
cd d:\Rcompile\CRANpkg\make
R CMD BATCH --no-restore --no-save Auto-Pakete-recompile.R log\Auto-Pakete-old-recompile.Rout
call check_diffs_send
exit
