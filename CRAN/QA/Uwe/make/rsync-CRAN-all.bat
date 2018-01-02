set Path=d:\compiler\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem
set HOME=/cygdrive/c/Users/ligges

pause

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.5 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.5/ ligges@shell:/home/ligges/CRANcheck/3.5

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.4 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.4/ ligges@shell:/home/ligges/CRANcheck/3.4

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.3 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.3/ ligges@shell:/home/ligges/CRANcheck/3.3

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.2 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.2/ ligges@shell:/home/ligges/CRANcheck/3.2

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.1 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.1/ ligges@shell:/home/ligges/CRANcheck/3.1

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/3.0 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/3.0/ ligges@shell:/home/ligges/CRANcheck/3.0

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.15 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.15/ ligges@shell:/home/ligges/CRANcheck/2.15

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.14 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.14/ ligges@shell:/home/ligges/CRANcheck/2.14

rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/win/2.13 ligges@shell:/home/ligges/CRAN
rsync -a --delete --chmod g+rx --chmod o+rx -e "ssh -o NumberOfPasswordPrompts=0 -i /cygdrive/c/Users/ligges/id_rsa" /cygdrive/d/RCompile/CRANpkg/check/2.13/ ligges@shell:/home/ligges/CRANcheck/2.13
