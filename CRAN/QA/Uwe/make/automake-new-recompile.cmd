pause
call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_devel64_Env.bat 
set mailMaintainer=no

d:
cd d:\Rcompile\CRANpkg\make
R CMD BATCH --no-restore --no-save Auto-Pakete-recompile.R log\Auto-Pakete-recompile.Rout
call check_diffs_send
exit
