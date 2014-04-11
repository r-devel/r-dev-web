set Path=d:\compiler\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.1 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.1/ ligges@shell:/home/ligges/CRANcheck/3.1

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.0 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.0/ ligges@shell:/home/ligges/CRANcheck/3.0

rem rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.15 ligges@shell:/home/ligges/CRAN
rem rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.15/ ligges@shell:/home/ligges/CRANcheck/2.15

rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/checkSummaryWin.html ligges@shell:/home/ligges/CRAN/checkSummaryWin.html
rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/ReadMe ligges@shell:/home/ligges/CRAN/ReadMe
rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/ThirdPartySoftware.html ligges@shell:/home/ligges/CRAN/ThirdPartySoftware.html