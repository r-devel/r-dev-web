pause
call d:\RCompile\CRANpkg\make\set_ENV_new.bat 
call d:\RCompile\CRANpkg\make\set_devel_Env.bat 
set mailMaintainer=no
rem set mailMaintainer=error

d:
cd d:\Rcompile\CRANpkg\make
R CMD BATCH --no-restore --no-save Auto-Pakete.R log\Auto-Pakete-new.Rout
rem exit
