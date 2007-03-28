all: fixtar CRAN

fixtar: src/fixtar.c
	gcc -s -o fixtar src/fixtar.c
	sudo chown root:admin fixtar
	sudo chmod a+s fixtar

packages:

cache: CRAN Makefile.CRAN
	$(MAKE) -C CRAN -f ../Makefile.CRAN cache

CRAN: CRAN.meta
	mkdir -p CRAN/src/contrib
	@(echo "*** use 'sync.bioc.in' to run CRAN+BioC sync")

CRAN.meta:
	mkdir CRAN.meta

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all packages clean
