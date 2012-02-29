set Path=d:\compiler\gcc\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.15 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.15/ ligges@shell:/home/ligges/CRANcheck/2.15

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.14 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.14/ ligges@shell:/home/ligges/CRANcheck/2.14

rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/checkSummaryWin.html ligges@shell:/home/ligges/CRAN/checkSummaryWin.html
rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/ReadMe ligges@shell:/home/ligges/CRAN/ReadMe
rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/ThirdPartySoftware.html ligges@shell:/home/ligges/CRAN/ThirdPartySoftware.html