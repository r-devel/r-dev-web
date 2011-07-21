set Path=d:\compiler\gcc\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.13 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.13/ ligges@shell:/home/ligges/CRANcheck/2.13

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.12 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.12/ ligges@shell:/home/ligges/CRANcheck/2.12

rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/checkSummaryWin.html ligges@shell:/home/ligges/CRAN/checkSummaryWin.html
rsync --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i c:/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/ReadMe ligges@shell:/home/ligges/CRAN/ReadMe
