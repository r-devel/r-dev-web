all: watchdog sched should_build CRAN

sched: src/sched.c
	gcc -o $@ $^ -O3

watchdog: src/watchdog.c
	gcc -o $@ $^ -O3

should_build: src/should_build.c
	gcc -Wall -o $@ $^ -O3

packages:

cache: CRAN Makefile.CRAN
	$(MAKE) $(MAKEFLAGS) -C CRAN -f ../Makefile.CRAN cache

CRAN: CRAN.meta
	mkdir -p CRAN/src/contrib
	@(echo "*** use 'sync.bioc.in' to run CRAN+BioC sync")

CRAN.meta:
	mkdir CRAN.meta

bioc.cache:
	$(MAKE) $(MAKEFLAGS) -C BIOC.new cache

help:
	@(echo ''; echo ' Targets: all (watchdog, sched, CRAN), cache, bioc.cache, clean'; echo '')

clean:
	rm -rf *~
	-rm -rf /tmp/CRAN.* /tmp/Rinst* /tmp/Rtmp*

.PHONY: all packages clean bioc.cache
