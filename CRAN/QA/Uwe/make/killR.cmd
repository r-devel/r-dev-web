call d:\RCompile\CRANpkg\make\set_recent_Env.bat 

pskill -t AcroRd32.exe
pskill -t firefox.exe
pskill -t WerFault.exe

d:
cd d:\Rcompile\CRANpkg\make
R -f killR.R --vanilla --quiet --args R_default_packages=NULL

exit
