call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_recent_Env.bat 

rem set maj.version=2.6+2.7+2.8+2.9+2.10+2.11+2.12+2.13+2.14
set maj.version=2.13


d:
cd d:\Rcompile\CRANpkg\make
R CMD BATCH --no-restore --no-save writeCRANpackages.R log\writeCRANpackages.Rout
exit
